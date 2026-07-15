$ExtDir = "$env:USERPROFILE\.positron\extensions"

$Remove = @(
"pkief.material-icon-theme",
"zhuangtongfa.material-theme",
"nadim-vscode.infinity-dark-theme",
"rokoroku.vscode-theme-darcula",
"nextgencode.jarvis-3d-theme",
"jrdev.vsc-theme-generator",
"streamline.streamline-icons",
"crsx.icons-library",
"superant.mc-dp-icons",
"sergeyegorov.folder-color",
"naumovs.color-highlight",
"sapegin.emoji-console-log",
"eliostruyf.spfx-snippets",
"tahabasri.snippets",
"nadim-vscode.twig-code-snippets",
"nadim-vscode.symfony-code-snippets"
)

if (!(Test-Path $ExtDir)) {
    Write-Host "Extensions folder not found."
    exit
}

foreach ($name in $Remove) {

    Get-ChildItem $ExtDir -Directory |
    Where-Object { $_.Name -like "$name*" } |
    ForEach-Object {

        Write-Host ("Removing: " + $_.FullName)

        Remove-Item $_.FullName -Recurse -Force

    }

}

Write-Host ""
Write-Host "Done."
