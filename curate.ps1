$ExtDir="$env:USERPROFILE\.positron\extensions"

$Profile="$PSScriptRoot\..\profiles\S-Class.txt"

$Output="$PSScriptRoot\..\reports"

New-Item $Output -ItemType Directory -Force|Out-Null

$White=Get-Content $Profile

$result=@()

foreach($dir in Get-ChildItem $ExtDir -Directory){

    $name=$dir.Name

    $base=$name

    if($name -match '^(.*?)-((\d+\.)+\d+.*)$'){
        $base=$matches[1]
    }

    $size=(Get-ChildItem $dir.FullName -Recurse -File -ErrorAction SilentlyContinue|
        Measure Length -Sum).Sum

    if($White -contains $base){

        $level="S"

    }

    else{

        $level="?"

    }

    $result+=[PSCustomObject]@{

        Extension=$base

        Folder=$dir.Name

        SizeMB=[math]::Round($size/1MB,2)

        Level=$level

    }

}

$result|
Sort Level,SizeMB -Descending|
Export-Csv "$Output\Research_Profile.csv" -NoTypeInformation -Encoding UTF8

Write-Host ""

Write-Host "完成！"

Write-Host "$Output\Research_Profile.csv"
