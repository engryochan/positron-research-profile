$ExtDir="$env:USERPROFILE\.positron\extensions"

$groups=Get-ChildItem $ExtDir -Directory |
Group-Object{

    if($_.Name -match "^(.*?)-((\d+\.)+\d+.*)$"){
        $matches[1]
    }
    else{
        $_.Name
    }

}

foreach($g in $groups){

    if($g.Count -gt 1){

        $sorted=$g.Group|Sort-Object Name -Descending

        $sorted|
        Select-Object -Skip 1|
        ForEach-Object{

            Write-Host "删除旧版本：$($_.Name)" -ForegroundColor Cyan

            Remove-Item $_.FullName -Recurse -Force

        }

    }

}
