# =====================================================
# Positron Research Profile
# Extension Scanner v1.0
# Author: OpenAI + Ryochan
# =====================================================

$ErrorActionPreference = "SilentlyContinue"

#-------------------------------------------------------
# Positron 扩展目录
#-------------------------------------------------------
$ExtDir = Join-Path $env:USERPROFILE ".positron\extensions"

if (!(Test-Path $ExtDir)) {
    Write-Host ""
    Write-Host "找不到 Positron Extensions：" -ForegroundColor Red
    Write-Host $ExtDir
    exit
}

#-------------------------------------------------------
# 输出目录
#-------------------------------------------------------
$RepoRoot = $PSScriptRoot
$ReportDir = Join-Path $RepoRoot "reports"

if (!(Test-Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir | Out-Null
}

#-------------------------------------------------------
# 开始扫描
#-------------------------------------------------------
$dirs = Get-ChildItem $ExtDir -Directory

$total = $dirs.Count
$index = 0

$result = @()

Write-Host ""
Write-Host "========================================"
Write-Host "Positron Extension Scanner v1.0"
Write-Host "========================================"
Write-Host ""

foreach ($dir in $dirs) {

    $index++

    Write-Progress `
        -Activity "Scanning Extensions..." `
        -Status "$index / $total" `
        -PercentComplete (($index / $total) * 100)

    $size = (
        Get-ChildItem $dir.FullName -Recurse -File |
        Measure-Object Length -Sum
    ).Sum

    $folder = $dir.Name

    $base = $folder
    $version = ""

    if ($folder -match '^(.*?)-((\d+\.)+\d+.*)$') {
        $base = $matches[1]
        $version = $matches[2]
    }

    $result += [PSCustomObject]@{

        Extension = $base

        Version = $version

        Folder = $folder

        SizeMB = [math]::Round($size / 1MB,2)

        SizeGB = [math]::Round($size / 1GB,3)

    }

}

Write-Progress -Completed -Activity "Scanning"

#-------------------------------------------------------
# 排序
#-------------------------------------------------------
$result = $result | Sort-Object SizeMB -Descending

#-------------------------------------------------------
# 导出 CSV
#-------------------------------------------------------
$CsvFile = Join-Path $ReportDir "Research_Profile.csv"

$result |
Export-Csv $CsvFile `
-NoTypeInformation `
-Encoding UTF8

#-------------------------------------------------------
# 显示 TOP30
#-------------------------------------------------------
Write-Host ""
Write-Host "============= TOP30 Largest Extensions =============" -ForegroundColor Yellow

$result |
Select-Object -First 30 |
Format-Table Extension,Version,SizeGB -AutoSize

#-------------------------------------------------------
# 汇总
#-------------------------------------------------------
$totalSize = ($result | Measure-Object SizeGB -Sum).Sum

Write-Host ""
Write-Host "========================================"
Write-Host "扫描完成！" -ForegroundColor Green
Write-Host "扩展数量：" $result.Count
Write-Host ("总容量：{0:N2} GB" -f $totalSize)
Write-Host ""
Write-Host "CSV 报告："
Write-Host $CsvFile -ForegroundColor Cyan
Write-Host "========================================"
