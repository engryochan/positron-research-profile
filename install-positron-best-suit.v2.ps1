# ============================================================
# Positron 開荒安裝腳本 v2（修正版）
# ------------------------------------------------------------
# 本檔取代 install-positron-with-best-suit.ps1（舊檔原樣封存，不改）。
# 修正要點：
#   1. 【永久排除 kilo-code】舊檔第 18 行的
#        positron --install-extension kilocode.kilo-code
#      已於 2026-10-10 從本清單剔除，日後安裝一律不納入。
#      理由：kilo 唯一勝過 Cline 的獨門是「行內補全」，而 Continue 已覆蓋；
#            二者補全＋快捷鍵（tab / ctrl+l 等五組）必然互擾，無法潔淨並存。
#            移除後功能無損（Continue 補全＋Cline 代理＋Claude Code 全覆蓋），省 520 MB。
#   2. 其餘沿用舊檔原意；版本只升不降，派森與工具鏈一律置於 C:\work（見研究報告）。
# ============================================================

# 用 winget 裝最新穩定版（禁用預發布 / RC，穩定性優先）
winget install --id Posit.Positron -e --source winget

positron --version
Get-ChildItem "$env:USERPROFILE\.positron\extensions" -Directory | Measure-Object

# ---- 核心擴展（kilo-code 已永久排除，不在此列）----
positron --install-extension posit.positron-r
positron --install-extension quarto.quarto
positron --install-extension charliermarsh.ruff
positron --install-extension ms-toolsai.jupyter
positron --install-extension randomfractalsinc.vscode-data-preview
positron --install-extension hediet.vscode-drawio
positron --install-extension anthropic.claude-code
# positron --install-extension kilocode.kilo-code   # ← 永久排除，切勿啟用（見上方理由）

# 驗證擴展數量（kilo 已除，較舊檔少 1）
Get-ChildItem "$env:USERPROFILE\.positron\extensions" -Directory | Measure-Object
