$Folders = @(
    "$env:USERPROFILE\AppData\Local",
    "$env:USERPROFILE\AppData\Roaming",
    "$env:ProgramData",
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\Windows"
)

$result = @()

foreach ($folder in $Folders) {

    if (!(Test-Path $folder)) { continue }

    Write-Host ""
    Write-Host "Scanning $folder ..." -ForegroundColor Cyan

    Get-ChildItem $folder -Directory -Force -ErrorAction SilentlyContinue |
    ForEach-Object {

        $size = (
            Get-ChildItem $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object Length -Sum
        ).Sum

        $result += [PSCustomObject]@{
            Folder = $_.FullName
            SizeGB = [math]::Round($size/1GB,2)
        }

    }

}

$result |
Sort-Object SizeGB -Descending |
Export-Csv "$HOME\Desktop\LargestFolders.csv" -NoTypeInformation -Encoding UTF8

$result |
Sort-Object SizeGB -Descending |
Select-Object -First 100 |
Format-Table -AutoSize

Write-Host ""
Write-Host "结果已保存到：" -ForegroundColor Green
Write-Host "$HOME\Desktop\LargestFolders.csv"
