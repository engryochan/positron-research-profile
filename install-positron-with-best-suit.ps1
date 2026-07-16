# 用 winget 装最新稳定版，最省事
winget install --id Posit.Positron -e --source winget

# 如果你想装预发布版，去 GitHub 拉
# winget install --id Posit.Positron --version 2026.07.0-... 

positron --version
Get-ChildItem "$env:USERPROFILE\.positron\extensions" -Directory | Measure-Object
# 应该是 0 个

positron --install-extension posit.positron-r
positron --install-extension quarto.quarto
positron --install-extension charliermarsh.ruff
positron --install-extension ms-toolsai.jupyter
positron --install-extension randomfractalsinc.vscode-data-preview
positron --install-extension hediet.vscode-drawio
positron --install-extension anthropic.claude-code
positron --install-extension kilocode.kilo-code

# 安装后，可以验证扩展数量（应该为 8）
Get-ChildItem "$env:USERPROFILE\.positron\extensions" -Directory | Measure-Object
