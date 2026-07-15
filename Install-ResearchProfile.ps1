# ============================================================
# Positron Research Profile Installer v1.0
# 功能：
# 1. 备份当前扩展
# 2. 删除同一扩展的旧版本（仅保留最新版）
# 3. 输出当前扩展统计
# ============================================================

$ErrorActionPreference = "Stop"

$ExtDir = Join-Path $env:USERPROFILE ".positron\extensions"

if (!(Test-Path $ExtDir)) {
    Write-Host "未找到 Positron 扩展目录：" -ForegroundColor Red
    Write-Host $ExtDir
    exit
}

$Repo = $PSScriptRoot

$BackupDir = Join-Path $Repo ("backup\" + (Get-Date -Format "yyyyMMdd_HHmmss"))

New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

Write-Host ""
Write-Host "========== Positron Research Profile ==========" -ForegroundColor Cyan
Write-Host ""

Write-Host "正在备份扩展……" -ForegroundColor Yellow

Copy-Item `
    "$ExtDir\*" `
    $BackupDir `
    -Recurse `
    -Force

Write-Host "备份完成：" -ForegroundColor Green
Write-Host $BackupDir
Write-Host ""

#---------------------------------------------------------
# 收集所有扩展
#---------------------------------------------------------

$Extensions = @{}

foreach ($dir in Get-ChildItem $ExtDir -Directory) {

    $folder = $dir.Name

    if ($folder -match '^(.*?)-((\d+\.)+\d+.*)$') {

        $name = $matches[1]
        $version = $matches[2]

    }
    else {

        $name = $folder
        $version = "0"

    }

    if (!$Extensions.ContainsKey($name)) {
        $Extensions[$name] = @()
    }

    $Extensions[$name] += [PSCustomObject]@{
        Folder = $folder
        Version = $version
        Path = $dir.FullName
    }
}

Write-Host "检查重复版本……" -ForegroundColor Yellow

$RemoveList = @()

foreach ($item in $Extensions.GetEnumerator()) {

    $list = $item.Value

    if ($list.Count -gt 1) {

        $sorted = $list | Sort-Object Version -Descending

        $keep = $sorted[0]

        Write-Host ""
        Write-Host ("保留：" + $keep.Folder) -ForegroundColor Green

        foreach ($old in $sorted | Select-Object -Skip 1) {

            Write-Host ("删除：" + $old.Folder) -ForegroundColor Yellow

            Remove-Item $old.Path -Recurse -Force

            $RemoveList += $old

        }

    }

}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ("扩展总数：" + (Get-ChildItem $ExtDir -Directory).Count)
Write-Host ("删除旧版本：" + $RemoveList.Count)
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Research Profile 初始化完成！" -ForegroundColor Green
