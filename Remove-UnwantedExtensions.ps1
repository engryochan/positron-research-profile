$ExtDir = Join-Path $env:USERPROFILE ".positron\extensions"

$Repo = $PSScriptRoot

$KeepFile = Join-Path $Repo "knowledge\keep.txt"

$Backup = Join-Path $Repo "backup"

New-Item $Backup -ItemType Directory -Force | Out-Null

$Keep = Get-Content $KeepFile

$dirs = Get-ChildItem $ExtDir -Directory

foreach($dir in $dirs){

    $folder = $dir.Name

    $base = $folder

    if($folder -match '^(.*?)-((\d+\.)+\d+.*)$'){
        $base = $matches[1]
    }

    if($Keep -contains $base){

        Write-Host "KEEP : $folder" -ForegroundColor Green

    }
    else{

        Write-Host "REMOVE : $folder" -ForegroundColor Yellow

        Copy-Item $dir.FullName $Backup -Recurse -Force

        Remove-Item $dir.FullName -Recurse -Force

    }

}

Write-Host ""
Write-Host "完成！"
