# Positron 研究工作台 · 遷移查證與實測報告

| 項目 | 內容 |
|---|---|
| 報告日期 | 2026-10-06；**2026-10-09 複核（第九節）並依指示變更 WSL2／派森統一／venvPath（第十節）** |
| 新主機 | `SHJ-H0647-RYOCH`／使用者 `PPCCpcpc` |
| 舊主機 | `PCCPPPCCC`（依 `positron已安裝的扩展列表.txt` 內殘留的提示符還原） |
| 硬體 | Intel i5-12400（6 核 12 執行緒）／31.8 GB RAM／Windows 10 Pro 19045 |
| 倉庫分支 | `世博量化研究院` @ `ba27dfc` |
| 本輪倉庫改動 | **0**（既有 41 個文件一律未改，`git diff` 為空；僅新增本報告） |
| 結論 | 組件齊備、**版本退化 0 項**、實測全數通過；WSL2 3.0.1.0 已裝（無發行版，**待重開機生效**）、派森已統一為單一 3.13.16、`python.venvPath` 已設 |

---

## 一、查證：本項目 41 個文件的角色盤點

全部文件已逐一讀取，未作任何修改。

### 1.1 推薦／保留清單（本輪「目標組件集」的依據）

| 文件 | 內容 | 用途 |
|---|---|---|
| `ResearchProfile.txt` | 27 個擴展，分 6 類（Language／Git／AI／Visualization／Docker／Web） | 主清單 |
| `install-positron-with-best-suit.ps1` | winget 裝 Positron + 8 個核心擴展 | 全新機開荒腳本 |
| `keep.json` | 12 個擴展的 S／A 評級 | 保留白名單 |
| `categories.json` | 6 類共 16 個擴展 | 分類白名單 |
| `scores.json` | 4 個擴展的百分制評分與理由 | 評測資料 |
| `高效率程序包.qmd` | **派森**：fastexcel、fastxlsx、calamine、polars、xlsx2csv；**鄀（R）**：openxlsx2、data.table | 程序包主清單 |

### 1.2 舊主機現狀快照（屬「清理前」狀態，**不是**安裝目標）

`positron已安裝的扩展列表.txt`（2867 行）、`Research_Profile.csv`（2488 筆）、`reports/Research_Profile.csv`（2500 筆）、`reports/Research_Report.md`（2500 個擴展，單是前 30 名就約 12 GB）、`reports/Large.csv`、`reports/Duplicate.csv`、`reports/Caches.csv`、`reports/DiskAnalysis_20260716_144543.txt`。

> 這批文件記錄的是舊主機「把市集幾乎裝了一遍」的失控狀態，倉庫裡的 `Remove-*.ps1` 與 `generate_remove.py` 正是為清理它而寫。**本輪並未依這 2500 份清單安裝**，只依 1.1 的策展清單安裝。

### 1.3 工具腳本（已實測可用，詳見第六節）

`curate.py`（v1.5 掃描產報告）、`curate.ps1`（同功能 PowerShell 版）、`classify.py`（規則分類）、`generate_remove.py`（產 Keep／Remove／Review）、`remove.py`（**破壞性**刪除）、`Install-ResearchProfile.ps1`、`Backup.txt`、`Remove-DuplicatedExtensions.ps1`、`Remove-UnwantedExtensions.ps1`、`Remove-VisualExtensions.ps1`、`Scan-BigFolders.ps1`、`Scan-Caches.ps1`、`Find-LargeFiles.ps1`、`replace.json`、`remove.json`、`vendors.json`（0 位元組空檔）。

### 1.4 查證中發現的 4 項隱患（僅報告，未修改）

1. **`高效率程序包.qmd` 不可直接用 Quarto 渲染。** 其標為 `bash` 的程式區塊實際是 PowerShell，會覆寫 `~/.wslconfig` 並執行 `wsl --shutdown`。渲染該文件等同無預警改設定並關閉 WSL。本輪改用另寫的安全探針文件驗證 Quarto（見 6.6）。
2. **`Remove-UnwantedExtensions.ps1` 讀取 `knowledge\keep.txt`，該路徑在倉庫中不存在。** 腳本會把保留清單讀成空值，於是**刪光全部擴展**（雖有備份動作）。目前狀態下請勿執行。
3. **`Remove-DuplicatedExtensions.ps1` 以字串排序判定「最新版」。** 遇到 `openai.chatgpt` 的 `26.5707.71524` 與 `26.721.30844` 會誤判（字串上 `26.7…` 大於 `26.5…`，數值上相反）。本輪清理殘留目錄時因此改用「以 Positron 實際啟用版本為準」的做法。
4. **`.wslconfig`（倉庫內）與 `高效率程序包.qmd` 的參數不一致**：倉庫版 `memory=12GB` 且把 5 項網路／進階鍵全部註解掉，qmd 版 `memory=24GB` 且全部啟用。兩者皆原樣保留未動。

---

## 二、「目標組件集」如何推導

取 1.1 四份策展清單的**聯集**，再按下列規則收斂：

- Positron 2026.09.1 已**內建**的能力，不再從市集重裝（重裝會造成衝突或版本倒退）。
- Positron 的擴展來源是 **OpenVSX**（`product.json` 指向 `https://p3m.dev/openvsx/...`），並非微軟市集，因此微軟專有擴展無法取得，改以內建或同類替代。
- 2500 份失控清單不列入目標。

---

## 三、Positron 擴展

### 3.1 總覽

| 指標 | 本輪前 | 10-06 完成時 | 10-09 複核 |
|---|---:|---:|---:|
| 啟用擴展數 | 14 | 36 | **37** |
| 磁碟目錄數 | 14 | 36 | **37** |
| 重複版本 | 0 | 0 | **0** |
| 總容量 | — | 3.11 GB | **3.89 GB** |

（對照舊主機：2500 個擴展，前 30 名即約 12 GB。）

> 10-09 多出的 1 個是 `aurora-them-creator.theme-aurora-nocturne@1.0.3`——**不在本項目任何策展清單內，也非本輪安裝**，詳見 9.2。

### 3.2 策展清單逐項落地情況

| 期望 ID（來源清單） | 本機結果 | 說明 |
|---|---|---|
| `ms-python.python` | ✅ **內建** `ms-python.python@2026.99.0-dev` | Positron 自帶分支版，版號高於市集版 |
| `posit.positron-r` | ✅ **內建** `positron.positron-r@0.0.2` | — |
| `ms-vscode.vscode-json` | ✅ **內建** `vscode.json@10.0.0` | — |
| `ms-vscode-remote.remote-containers` | ✅ **內建** `positron.dev-containers@0.0.1` 替代 | 微軟專有，OpenVSX 無 |
| `duckdb.duckdb` | ✅ **內建** `positron.positron-duckdb@0.0.1` 替代 | 另有 7 個 data-driver 內建擴展 |
| `ms-python.vscode-pylance` | ⚠️ 無法取得 → `meta.pyrefly@1.3.1` 替代 | 微軟授權限定，不得離開 MS 產品 |
| `github.copilot` | ⚠️ 無法取得 | 微軟專有；本機已有 8 套 AI 代理 |
| `plotly.plotly-vscode` | ⚠️ 註冊表無此擴展 | Positron 內建 Plots 面板已覆蓋 |
| `rooveterinaryinc.roocode` | ✅ `rooveterinaryinc.roo-cline@3.54.0` | 上游改名，舊 ID 已不存在 |
| `ms-azuretools.vscode-docker` | ✅ `2.0.0` + `vscode-containers@2.4.5` | 上游已拆分 |
| `charliermarsh.ruff` | ✅ `2026.84.0` | 升級 |
| `ms-toolsai.jupyter` | ✅ `2025.9.1`（另 4 個配套） | — |
| `quarto.quarto` | ✅ `1.138.0` | 升級 |
| `reditorsupport.r` | ✅ `3.0.1`（另 `r-syntax@0.1.4`） | 新裝 |
| `yzhang.markdown-all-in-one` | ✅ `3.6.2` | 新裝 |
| `james-yu.latex-workshop` | ✅ `10.19.0` | 新裝 |
| `eamodio.gitlens` | ✅ `19.3.0` | 新裝 |
| `github.vscode-pull-request-github` | ✅ `0.162.0` | 升級 |
| `openai.chatgpt` | ✅ `26.5707.71524` | 釘選至舊主機同版（見 3.4） |
| `continue.continue` | ✅ `2.1.0` | 釘選至註冊表最新（見 3.4） |
| `saoudrizwan.claude-dev` | ✅ `4.1.22` | 升級 |
| `anthropic.claude-code` | ✅ `2.1.291` | 升級 |
| `kilocode.kilo-code` | ✅ `7.8.3` | 升級 |
| `google.geminicodeassist` | ✅ `2.100.0` | 升級 |
| `tomoyukim.vscode-mermaid-editor` | ✅ `0.19.1` | 新裝 |
| `randomfractalsinc.vscode-data-preview` | ✅ `2.2.0` | 新裝 |
| `hediet.vscode-drawio` | ✅ `1.6.6` | 新裝 |
| `mechatroner.rainbow-csv` | ✅ `3.24.1` | 新裝 |
| `ms-mssql.mssql` | ✅ `1.46.0` | 新裝 |
| `dbaeumer.vscode-eslint` | ✅ `3.0.34` | 新裝 |
| `esbenp.prettier-vscode` | ✅ `12.4.0` | 新裝 |
| `bradlc.vscode-tailwindcss` | ✅ `0.16.0` | 新裝 |

另有本機原生的 `posit.air-vscode@0.30.0`、`posit.assistant@1.6.1`、`posit.publisher@2.13.16`、`posit.shiny@1.4.3`、`ms-python.debugpy@2026.6.0` 一併保留並升級。

**策展清單覆蓋率：32／35 直接或內建滿足；3 項（pylance／copilot／plotly）因授權或註冊表缺失不可得，均有替代。**

### 3.3 「只升不降」核對（對照舊主機 2474 筆版本記錄）

10-09 複核結果：

```
升級 13 項 | 相同 15 項 | 退化 0 項 | 舊清單未收錄 9 項
```

| 擴展 | 舊主機 | 10-06 | 10-09（最終） |
|---|---|---|---|
| posit.assistant | 0.7.0 | 1.6.1 | **1.7.0** |
| posit.publisher | 2.8.0 | 2.13.16 | **2.13.16** |
| posit.air-vscode | 0.26.0 | 0.30.0 | **0.30.0** |
| posit.shiny | 1.4.1 | 1.4.3 | **1.4.3** |
| charliermarsh.ruff | 2026.60.0 | 2026.84.0 | **2026.84.0** |
| quarto.quarto | 1.135.0 | 1.138.0 | **1.138.0** |
| meta.pyrefly | 1.1.1 | 1.3.1 | **1.3.1** |
| kilocode.kilo-code | 7.4.7 | 7.8.3 | **7.8.8** |
| anthropic.claude-code | 2.1.210 | 2.1.291 | **2.1.295** |
| saoudrizwan.claude-dev | 4.0.8 | 4.1.22 | **4.1.23** |
| google.geminicodeassist | 2.91.0 | 2.100.0 | **2.104.0** |
| github.vscode-pull-request-github | 0.144.0 | 0.162.0 | **0.162.0** |
| **openai.chatgpt** | 26.5707.71524 | 26.5707.71524（持平） | **26.5730.61309（轉為升級）** |

### 3.4 過程中出現並已修正的 2 次版本退化

市集鏡像 `p3m.dev` 回傳的「latest」會滯後於 OpenVSX 上游，首輪安裝因此踩到兩次退化，均已用釘選版本修正：

| 擴展 | 鏡像給的 latest | 舊主機版本 | 最終釘選 | 結果 |
|---|---|---|---|---|
| `continue.continue` | 2.0.0 | 2.1.0 | **2.1.0** | 已是上游最新 |
| `openai.chatgpt` | 26.721.30844 | 26.5707.71524 | **26.5707.71524** | 10-06 僅能與舊主機持平；10-09 鏡像同步後已自動升至 **26.5730.61309**，由「持平」轉為「升級」 |

釘選後留下 3 個舊版本殘留目錄（continue 2.0.0、chatgpt 26.721.30844、publisher 2.12.0），已依「Positron 實際啟用版本」精準刪除，現為 0 重複。

### 3.5 仍落後上游的 3 項（純屬鏡像同步延遲，皆不低於舊主機）

| 擴展 | 本機（10-09） | OpenVSX 上游 | 鏡像可安裝 |
|---|---|---|---|
| `eamodio.gitlens` | 19.3.0 | 2026.10.60516 | ✗（10-09 以 `--force` 重試，鏡像仍只有 19.3.0） |
| `github.vscode-pull-request-github` | 0.162.0 | 0.166.1 | ✗（同上） |
| `meta.pyrefly` | 1.3.1 | 1.3.9003 | ✗；且 9003 為預發行版，依「穩定性優先」本就不應採用 |

`openai.chatgpt` 原列於此，10-09 鏡像已同步並自動升級，已移出本表。鏡像同步後執行 `positron --update-extensions` 即可自動跟上。

---

## 四、派森（Python）：版本決策

> ⚠️ **本節為 10-06 的決策，已於 10-09 依指示改為「全機統一單一版本」而被取代。** 4.1～4.3 的現狀調查與相容性證據仍然有效且是新決策的依據；4.4 的三環境配置已失效，現行配置見 **10.2**。

### 4.1 本機原狀

PATH 上的 `python.exe` 是 **Microsoft Store 的 0 位元組佔位檔**，`pip` 不存在——等同沒有可用的 Python。實際解譯器由 `uv 0.12.23` 託管於 `C:\work\pythons`，原有 3.13.16 與 3.12.15。

### 4.2 候選與取捨

| 候選 | 狀態 | 判定 |
|---|---|---|
| 3.15.0rc3 | Release Candidate | **排除**——「穩定性最高」不能用 RC |
| **3.14.8** | 正式穩定版 | **採用**為主版本 |
| 3.13.16 | 本機原有 | 保留（reticulate 綁定） |
| 3.12.15 | 本機原有 | 保留（fastxlsx 專用） |

### 4.3 唯一的相容性瓶頸：`fastxlsx`

`fastxlsx 0.2.0` 上游宣告 `requires_python` 為 `<3.13,>=3.8`，預編譯輪子最高只到 `cp312`：

| 程序包 | 最新版 | requires_python | 預編譯輪子 |
|---|---|---|---|
| `fastexcel` | 0.21.0 | ≥3.10 | cp310、cp314 |
| `python-calamine` | 0.8.2 | ≥3.10 | cp310–cp314 |
| `polars` | 1.44.2 | ≥3.10 | py3（純通用） |
| `xlsx2csv` | 0.8.6 | 無限制 | py3 |
| **`fastxlsx`** | **0.2.0** | **<3.13** | **cp38–cp312** |

在 3.14 上 uv 會退回源碼編譯，因本機無 MSVC `link.exe` 而失敗——**這是該程序包自身已停止跟進，不是本機環境缺陷**。而若為它把主版本壓到 3.12，就會違反「只升不降」（本機原有 3.13.16）。

**採行方案：主環境升到 3.14.8，`fastxlsx` 的能力以 3.12 側環境保留——不丟功能，也不降主版本。**

### 4.4 三個環境的最終配置

| 環境 | 解譯器 | 定位 | 程序包 |
|---|---|---|---|
| `C:\work\envs\ds314` | **3.14.8**（新建） | **主環境** | fastexcel 0.21.0、python-calamine 0.8.2、polars 1.44.2、xlsx2csv 0.8.6、xlsxwriter 3.2.9、pandas 3.0.6、pyarrow 25.0.1、numpy 2.5.3、openpyxl 3.1.5、rich 15.0.0 |
| `C:\work\envs\ds` | 3.13.16（原有） | `RETICULATE_PYTHON` 指向，與鄀（R）互通 | 原 730 個程序包全數保留；**補裝 xlsx2csv 0.8.6**（原缺） |
| `C:\work\envs\xlsx312` | 3.12.15（新建） | `fastxlsx` 專用側環境 | fastxlsx 0.2.0、numpy 2.5.3 |

> 原有 `fin`／`mlops`／`nlp`／`rl`／`xai` 五個環境（皆 3.13.16）一律未動。

---

## 五、鄀（R）

| 程序包 | 本輪前 | 本輪後 |
|---|---|---|
| `openxlsx2` | **缺失** | **1.29（新裝）** |
| `data.table` | 1.18.6.1 | 1.18.6.1（已是 CRAN 最新） |

R 本體 4.6.1（2026-06-24 ucrt），庫路徑 `C:/work/R/R-4.6.1/library`；既有 `duckdb 1.5.6`、`tidyverse 2.0.0`、`languageserver 0.3.20`、`renv 1.3.0`、`readxl 1.5.0.1`、`writexl 2.0.1` 均保留。

---

## 六、實測明細（11 項全數通過）

### 6.1 派森 3.14.8 主環境

| 程序包 | 操作 | 耗時 | 結果 |
|---|---|---:|---|
| polars 1.44.2 | 寫 xlsx + csv（6366 B） | 314 ms | PASS |
| fastexcel 0.21.0 | 讀 xlsx 3×3 | 252 ms | PASS |
| python-calamine 0.8.2 | 讀 xlsx 4 列 | 73 ms | PASS |
| xlsx2csv 0.8.6 | xlsx → csv | 15 ms | PASS |
| fastxlsx | — | — | 不適用（上游釘死 `<3.13`，見 6.3） |

### 6.2 派森 3.13.16（reticulate 環境）

同 4 項全 PASS：polars 1306 ms／fastexcel 327 ms／calamine 85 ms／xlsx2csv 15 ms。

### 6.3 派森 3.12.15 側環境 — `fastxlsx`

| 操作 | 耗時 | 結果 |
|---|---:|---|
| `WriteOnlyWorkbook.write_matrix` → 存檔（5009 B） | 11.0 ms | PASS |
| `ReadOnlyWorkbook.read_value`（3×2 Float） | <1 ms | PASS，往返一致 |

### 6.4 鄀（R）4.6.1

| 程序包 | 操作 | 耗時 | 結果 |
|---|---|---:|---|
| openxlsx2 1.29 | `write_xlsx` → `read_xlsx`（6220 B，3×3） | 978／569 ms | PASS，往返一致 |
| data.table 1.18.6.1 | `fwrite` → `fread`（96 B，6 執行緒） | 29／3 ms | PASS，往返一致 |

### 6.5 跨語言互通（含中日韓字元）

| 方向 | 結果 |
|---|---|
| 鄀 `openxlsx2` 寫 → 派森 `fastexcel` 讀 | PASS，3×3，`浦发银行／贵州茅台／中国平安` 無亂碼 |
| 鄀 `openxlsx2` 寫 → 派森 `python-calamine` 讀 | PASS |
| 派森 `polars` 寫 → 鄀 `openxlsx2` 讀 | PASS，3×3 |

### 6.6 工具鏈與倉庫腳本

| 對象 | 結果 |
|---|---|
| Positron | `2026.09.1 build 2`（Code OSS 1.130.0，x64） |
| Quarto | `1.10.18`；`quarto check` 全 OK（Pandoc 3.10.0／Dart Sass 1.101.0／Deno 2.7.14／Typst 0.15.1／knitr 1.52） |
| Quarto 渲染 | 自建安全探針 `.qmd`（knitr + reticulate）→ 22135 B HTML，R 與派森區塊皆正確輸出 |
| uv | `0.12.23` |
| git | `2.55.0.windows.5` |
| `curate.py --top 10` | PASS：36 個擴展／0 重複／3.14 GB／7.0 秒 |
| `classify.py` | PASS → `Classified.csv` |
| `generate_remove.py` | PASS → `Keep.csv`／`Remove.csv`／`Review.csv` |
| `remove.py` | **未執行**（破壞性：會刪除擴展目錄） |

> 三個腳本一律在暫存目錄中以該處為工作目錄執行，輸出落在暫存區，**倉庫 `reports/` 下的現有文件完全未被覆寫**。

---

## 七、尚未處理、需您決定的 3 件事

> ⚠️ **7.1 與 7.2 已於 10-09 依指示完成，見第十節。** 以下保留原始評估記錄。

### 7.1 WSL2 虛擬 Linux（唯一的真正缺口）

本機 `wsl.exe` 存在但**無任何發行版**，且 `C:\Users\PPCCpcpc\.wslconfig` **不存在**。倉庫的 `.wslconfig` 與 qmd 中的調校腳本因此尚無作用對象。

未自行安裝的理由：需要管理員權限與重新開機，且會寫入 `~/.wslconfig`——屬於超出「Positron 組件、程序包」範圍、且不易回退的系統級改動。

若要補齊（**需管理員 PowerShell，會重開機**）：

```powershell
wsl --install -d Ubuntu --web-download
```

硬體對照：本機 12 執行緒／31.8 GB RAM，與倉庫 `.wslconfig` 假設的 12 執行緒相符；`memory` 可照 qmd 的 24GB 設定（倉庫現存版本寫 12GB）。請注意第 1.4.1 條——**不要用 Quarto 去渲染套用那段設定**，請手動複製該區塊內容執行。

### 7.2 讓 Positron 下拉選單直接看到 `C:\work\envs` 的環境

`%APPDATA%\Positron\User\settings.json` 目前未設解譯器搜尋路徑。`ds` 環境靠 `RETICULATE_PYTHON` 可用，但新建的 `ds314` 與 `xlsx312` 未必出現在解譯器選單。此為既有設定檔，未擅自改動。建議新增：

```json
"python.venvPath": "C:\\work\\envs"
```

### 7.3 鏡像同步後再補一次升級

3.5 節的 4 項待 `p3m.dev` 同步。屆時執行：

```powershell
positron --update-extensions
```

---

## 八、本輪實際執行的指令（可復現）

```powershell
# 派森：最新穩定版（3.15 仍為 RC，排除）
uv python install 3.14

# 主環境
uv venv C:\work\envs\ds314 --python 3.14
uv pip install --python C:\work\envs\ds314\Scripts\python.exe `
  fastexcel python-calamine polars xlsx2csv pandas rich pyarrow openpyxl xlsxwriter

# 既有 ds 環境補缺（只增不減）
uv pip install --python C:\work\envs\ds\Scripts\python.exe --upgrade `
  fastexcel python-calamine polars xlsx2csv

# fastxlsx 側環境（上游釘死 <3.13）
uv venv C:\work\envs\xlsx312 --python 3.12
uv pip install --python C:\work\envs\xlsx312\Scripts\python.exe fastxlsx

# 鄀（R）
Rscript -e "install.packages('openxlsx2', repos='https://cloud.r-project.org')"

# Positron 擴展（21 項新裝／升級，含 2 項釘選修正退化）
positron --install-extension reditorsupport.r
positron --install-extension yzhang.markdown-all-in-one
positron --install-extension james-yu.latex-workshop
positron --install-extension eamodio.gitlens
positron --install-extension saoudrizwan.claude-dev
positron --install-extension anthropic.claude-code
positron --install-extension kilocode.kilo-code
positron --install-extension rooveterinaryinc.roo-cline
positron --install-extension tomoyukim.vscode-mermaid-editor
positron --install-extension randomfractalsinc.vscode-data-preview
positron --install-extension hediet.vscode-drawio
positron --install-extension mechatroner.rainbow-csv
positron --install-extension dbaeumer.vscode-eslint
positron --install-extension esbenp.prettier-vscode
positron --install-extension bradlc.vscode-tailwindcss
positron --install-extension ms-azuretools.vscode-docker
positron --install-extension google.geminicodeassist
positron --install-extension ms-mssql.mssql
positron --install-extension posit.publisher@2.13.16
positron --install-extension continue.continue@2.1.0         # 修正 2.0.0 退化
positron --install-extension openai.chatgpt@26.5707.71524    # 修正版號退化
```

---

## 九、2026-10-09 複核

### 9.1 期間自動升級的 6 項（全部為升級，無退化）

| 擴展 | 10-06 | 10-09 |
|---|---|---|
| `anthropic.claude-code` | 2.1.291 | **2.1.295** |
| `openai.chatgpt` | 26.5707.71524 | **26.5730.61309** |
| `google.geminicodeassist` | 2.100.0 | **2.104.0** |
| `kilocode.kilo-code` | 7.8.3 | **7.8.8** |
| `posit.assistant` | 1.6.1 | **1.7.0** |
| `saoudrizwan.claude-dev` | 4.1.22 | **4.1.23** |

`claude-code` 升級後留下 `2.1.294` 殘留目錄，已依「以 Positron 實際啟用版本為準」刪除；現 **37 個目錄／37 個啟用／0 重複／3.89 GB**。

### 9.2 出現 1 個不屬於本項目的主題擴展

`aurora-them-creator.theme-aurora-nocturne@1.0.3` 既不在 `ResearchProfile.txt`／`keep.json`／`categories.json`／`install-positron-with-best-suit.ps1` 任何一份策展清單中，也不是本輪安裝的。

依本項目既有策展政策，這類擴展本屬移除對象——`generate_remove.py` 會把它分類為 `Theme` 並寫入 `Remove.csv`，`Remove-VisualExtensions.ps1` 的硬編碼名單也正是同類主題。

**已確認為使用者自行設定的主題，予以保留**；`settings.json` 中亦有對應的 `"workbench.colorTheme": "Aurora Nocturne"`。

> 本項目日後若執行 `generate_remove.py` → `remove.py` 的清理鏈，**此擴展會被誤刪**，執行前請先把它從 `Remove.csv` 剔除，或加進 `keep.json`。

### 9.3 複核實測結果（11/11 再次全數通過）

| 項目 | 結果 |
|---|---|
| 派森 3.14.8（ds314） | polars 652 ms／fastexcel 442 ms／calamine 92 ms／xlsx2csv 16 ms — 4/4 PASS |
| 派森 3.13.16（ds） | polars 549 ms／fastexcel 415 ms／calamine 96 ms／xlsx2csv 15 ms — 4/4 PASS |
| 派森 3.12.15（xlsx312） | fastxlsx 寫 10.1 ms／讀 <1 ms，往返一致 — PASS |
| 鄀（R）4.6.1 | openxlsx2 寫 347 ms／讀 38 ms；data.table 2 ms／2 ms，均往返一致 — PASS |
| 跨語言互通 | 雙向 3 項全 PASS，中日韓字元無亂碼 |
| 工具鏈 | Positron 2026.09.1 build 2／Quarto 1.10.18／uv 0.12.23 — 一致 |

### 9.4 第七節 3 項待決事項狀態

| 事項 | 狀態 |
|---|---|
| 7.1 WSL2 安裝 | 10-09 **已完成**，見 10.1 |
| 7.2 `python.venvPath` 設定 | 10-09 **已完成**，見 10.3 |
| 7.3 鏡像同步後補升級 | 已執行 `--update-extensions`；`openai.chatgpt` 已追上，餘 3 項鏡像尚未同步（見 3.5） |

---

## 十、2026-10-09 依指示執行的三項變更

### 10.1 安裝 WSL2 穩定版，不帶任何發行版

安裝前狀態：`Microsoft-Windows-Subsystem-Linux` 與 `VirtualMachinePlatform` 皆 **Disabled**；`wsl.exe` 僅為 Windows 10 內建舊版（不支援 `--version`）。BIOS 虛擬化已開啟（`VirtualizationFirmwareEnabled = True`）。

以提權執行：

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
wsl.exe --install --no-distribution --web-download
```

安裝後：

| 項目 | 結果 |
|---|---|
| `VirtualMachinePlatform` | **Enabled** |
| `Microsoft-Windows-Subsystem-Linux` | **Enabled** |
| WSL 套件 | `MicrosoftCorporationII.WindowsSubsystemForLinux` **3.0.1.0** |
| WSL 版本 | WSL **3.0.1.0**／核心 **6.18.40.1-1**／WSLg 1.0.79／MSRDC 1.2.7214 |
| 發行版 | **0 個**（註冊表 `Lxss` 鍵下無任何登記，依指示不裝） |
| 生效條件 | **需重新啟動**（`wsl --list` 目前回報 `Wsl/WSL_E_WSL_OPTIONAL_COMPONENT_REQUIRED`） |

採用 `--web-download` 取得 GitHub 正式發行的**穩定版**（非 `--pre-release`，亦不依賴 Microsoft Store）。選 WSL 3.0.1.0 這條獨立套件路線而非 Windows 10 內建舊元件，正是為了相容最前沿的 `.wslconfig` 鍵——倉庫 `.wslconfig` 與 `高效率程序包.qmd` 所用的 `dnsTunneling`、`autoProxy`、`sparseVhd`、`autoMemoryReclaim`、`nestedVirtualization`、`pageReporting` **全部需要獨立套件版才支援**，舊內建元件一概不認。

### 10.2 派森統一為單一版本：3.13.16

**為什麼是 3.13.16 而非 3.14.8**——用 `uv pip compile` 對 42 項頂尖組件做實際依賴解析，兩個版本都能解出 279 個套件，但解出的**版本穩定度**不同：

| 組件 | 在 3.13 解出 | 在 3.14 解出 |
|---|---|---|
| `tensorflow` | **2.21.0（正式穩定版）** | **2.22.0rc0（候選版）** |
| `keras` | **3.15.1（正式穩定版）** | 解不出 → 改用 **keras-nightly 3.16.0.dev2026100904** |
| `h5py` | 3.14.0 | 3.15.1 |
| 其餘 276 項 | 完全相同 | 完全相同 |

亦即：**42 項頂尖組件中，只有 3.13 能讓全部都落在正式穩定版**；3.14 會把 TensorFlow 拖進 RC 並被迫引入 nightly 版 Keras。依「穩定版中兼容最多前沿高端頂尖組件」的標準，3.13.16 勝出。torch 2.14.1、jaxlib、numba 0.68、scipy、pyarrow、ray、catboost、quantlib、onnx、shap 等在兩個版本上都有 Windows 輪子，不構成差異。

附帶好處：3.13.16 原本就是本機 6 個既有環境、1387 筆套件安裝所在的版本，統一到它**不需要重建任何既有環境**。

執行內容：

| 動作 | 結果 |
|---|---|
| 移除 venv `ds314`（3.14.8） | 已刪 |
| 移除 venv `xlsx312`（3.12.15） | 已刪 |
| `uv python uninstall 3.14` | 已卸載 cpython-3.14.8 |
| `uv python uninstall 3.12` | 已卸載 cpython-3.12.15 |
| 修復殘破 shim | 見 10.4 |

`C:\work\pythons` 現僅存 3.13.16（`cpython-3.13-windows-x86_64-none` 與 `cpython-3.13.16-...` 是 uv 對**同一版本**的兩個目錄別名，非兩個版本；6 個環境全綁定前者，未動）。`C:\work\envs` 現為 `ds`／`fin`／`mlops`／`nlp`／`rl`／`xai` 六個，**全部 Python 3.13.16**。

**代價：`fastxlsx` 能力移除。** 該包上游釘死 `requires_python <3.13`，在統一為單一版本的前提下無處安放。替代方案已就位且均已實測：讀 xlsx 用 `fastexcel` 0.21.0 ／ `python-calamine` 0.8.2，寫 xlsx 用 `polars.write_excel`（後端 `xlsxwriter` 3.2.9）或 `openpyxl` 3.1.5，xlsx→csv 用 `xlsx2csv` 0.8.6。

### 10.3 `python.venvPath` 設定

`%APPDATA%\Positron\User\settings.json` 已備份為 `settings.json.bak-20261009`，然後新增兩行（其餘設定含您的 `workbench.colorTheme` 原樣保留，JSON 已驗證合法）：

```json
"python.venvPath": "C:\\work\\envs",
"python.defaultInterpreterPath": "C:\\work\\envs\\ds\\Scripts\\python.exe",
```

`venvPath` 讓 Positron 的解譯器選單直接列出 `C:\work\envs` 下全部 6 個環境；多加的 `defaultInterpreterPath` 讓新工作區預設落在主環境 `ds`（它是 `RETICULATE_PYTHON` 的指向，731 個套件）。

### 10.4 過程中處理掉的兩件意外

**(1) `browser-use` MCP 伺服器卡住 3.12 的刪除。** `uv python uninstall 3.12` 第一次回報「拒絕存取」。追查到 PID 209952 正在執行
`C:\work\pythons\cpython-3.12-windows-x86_64-none\python.exe ... browser-use.exe --cli-mcp`，
即本 session 的 `browser-use` MCP 伺服器，鏡像檔被映射而無法刪除。

未直接砍掉，先確認遷移安全：`browser-use` 0.13.11 宣告 `requires_python >=3.11,<4.0`，且 `uv pip compile` 驗證它連同 **106 個依賴在 3.13 上全部可解析**。它也不是常駐 `uv tool`（`uv tool list` 為空），而是由 MCP 用 uv 臨時啟動——3.12 消失後會自動改用 3.13。確認無虞後才停止該行程並完成卸載。

> 該 MCP 伺服器已被停止，會由用戶端自動重啟並改用 3.13；若本 session 的瀏覽器工具暫時無回應，重載 session 即可。

**(2) 修復一個既存的殘破 uv shim。** `C:\Users\PPCCpcpc\.local\bin\python3.13.exe`（46592 B，時間戳 2026-10-06 07:43，早於本任務）是指向已不存在解譯器的 uv trampoline，執行時報 `uv trampoline failed to spawn Python child process`。它一度讓 `uv pip install` 直接失敗（`error: Failed to inspect Python interpreter from first executable in the search path`）。已移除，uv 指令恢復正常（exit 0、無警告）。

### 10.5 統一後的完整回歸實測

| 項目 | 結果 |
|---|---|
| 唯一派森 3.13.16（ds） | polars 690 ms／fastexcel 400 ms／calamine 89 ms／xlsx2csv 15 ms — **4/4 PASS** |
| 鄀（R）4.6.1 | openxlsx2 寫 356 ms／讀 37 ms；data.table 3 ms／2 ms — **PASS**，均往返一致 |
| 跨語言互通 | 雙向 3 項 **全 PASS**，中日韓字元無亂碼 |
| 倉庫腳本 | `curate.py`（37 擴展／0 重複／3.89 GB／5.4 秒）、`classify.py`、`generate_remove.py` — **全 PASS** |
| Positron／擴展 | 2026.09.1 build 2／**37 個擴展**／0 重複 |

`fastxlsx` 一項按 10.2 的決定已不再適用，其餘全數通過。

### 10.6 還需您做一件事

**重新啟動電腦**，WSL2 才會生效。重開機後可驗證：

```powershell
wsl --status
wsl --list --verbose
```

屆時若要裝發行版（您目前指示先不裝）：

```powershell
wsl --install -d Ubuntu --web-download
```

套用倉庫的 `.wslconfig` 調校時，請手動複製 `高效率程序包.qmd` 中該區塊的內容執行，**不要用 Quarto 渲染該文件**（原因見 1.4.1）。

---

## 十一、Positron 與派森環境實測（2026-10-09，重開機前）

### 11.1 Positron 啟動實測

以 `C:\work\Positron\Positron.exe <本項目路徑>` 啟動：

| 檢查項 | 結果 |
|---|---|
| 行程 | **10 個**（主行程 + GPU/工具/擴展宿主） |
| 主視窗標題 | `Welcome - positron-research-profile - Positron` |
| 版本 | Positron 2026.09.1 build 2 |
| 擴展 | 37 個全部載入 |

**解譯器探索已生效的直接證據**：Positron 的派森擴展在 `%APPDATA%\Positron\User\globalStorage\ms-python.python\pycache\` 下建立了對應 `ds`／`fin`／`mlops`／`nlp`／`rl`／`xai` 六個環境加 `cpython-3.13.16` 的位元碼快取——這正是它透過 10.3 設定的 `python.venvPath` 掃到全部 6 個環境的結果。

### 11.2 派森執行期端到端實測（走 Positron 主控台同一條路徑）

Positron 的派森主控台是以 Jupyter 核心協定驅動的。用 `jupyter_client` 真正啟動核心並執行程式碼：

```
核心堆疊  ipykernel 7.3.0 / jupyter_client 8.10.0 / IPython 9.17.1
啟動核心  ds
kernel python : 3.13.16
kernel exe    : C:\work\envs\ds\Scripts\python.exe
sys.prefix    : C:\work\envs\ds
polars         : 1.44.2 | wrote 6341 B
fastexcel      : 0.21.0 | read (3, 3)
python-calamine: 0.8.2  | rows 4
roundtrip ok   : True
RESULT: PASS — 核心啟動、執行、讀寫全部成功
```

核心在 `C:\work` 內啟動、在核心內完成 xlsx 寫入與兩種讀取、中日韓字元往返一致後正常關閉。

### 11.3 kernelspec 全面稽核，並修掉一個故障核心

因 10.2 移除了 3.12／3.14，逐一檢查 7 個 kernelspec 的 `argv[0]`：

| kernelspec | 指向 | 稽核前 | 處置 |
|---|---|---|---|
| `ds`／`fin`／`mlops`／`nlp`／`rl`／`xai` | `C:\work\envs\<名>\Scripts\python.exe` | 正常 | — |
| `python3`（ds 環境內建） | 裸名 `"python"` | **故障** | 改為絕對路徑 |

`python3` 這個 kernelspec 用裸名 `python`，會從 PATH 解析——而 PATH 上的 `python` 是 `...\WindowsApps\python.exe`，一個 **0 位元組的 Microsoft Store 佔位檔**（實測執行無任何輸出）。已把 `argv[0]` 改為 `C:\\work\\envs\\ds\\Scripts\\python.exe`。現 **7 個 kernelspec 全部健康且全部指向 `C:\work` 內**。

### 11.4 把派森資產全數收攏進 `C:\work`，釋出 7.8 GB

依「切忌重疊安裝任何派森程序包在 `C:\work` 以外」的要求，掃描後發現並清除：

| 位置 | 內容 | 處置 |
|---|---|---|
| `%LOCALAPPDATA%\uv\cache` | **7.67 GB／20 萬檔**的 uv 快取（`archive-v0` 7.36 GB、`sdists-v9`、`simple-v25`、`wheels-v6`…），時間戳全為 2026-10-06 08:47 前，`uv cache dir` 早已改指 `C:\work\uv-cache` | **已刪**（部分超長路徑以 robocopy 鏡像空目錄清除） |
| `%APPDATA%\uv\python` | **完整派森安裝 120 MB**：cpython-3.12、3.12.15、3.13.16 各一套 | **已刪** |
| `%APPDATA%\uv\python`（第二次） | 60.3 MB，16:46 又被重建（見 11.6） | **已再刪** |

刪除前已逐項確認無引用：無行程佔用、全碟掃 `pyvenv.cfg` 無任何 venv 指向 AppData、`uv python list` 不收錄這些。

同時把 uv 剩下三個預設在 `C:\work` 之外的目錄變數鎖進 `C:\work`（User 層級持久設定）：

| 變數 | 原值 | 現值 |
|---|---|---|
| `UV_CACHE_DIR` | 已是 `C:\work\uv-cache` | 不變 |
| `UV_PYTHON_INSTALL_DIR` | 已是 `C:\work\pythons` | 不變 |
| `UV_TOOL_DIR` | 未設 → `%APPDATA%\uv\tools` | **`C:\work\uv-tools`** |
| `UV_TOOL_BIN_DIR` | 未設 | **`C:\work\uv-tools\bin`** |
| `UV_PYTHON_BIN_DIR` | 未設 | **`C:\work\pythons\bin`** |

另確認 `ds` 環境 `ENABLE_USER_SITE: False`、`USER_SITE` 不存在，`JUPYTER_DATA_DIR` 已是 `C:\work\jupyter`——沒有任何 user site-packages 旁路。

現況：派森資產全在 `C:\work`（`envs` 9.95 GB／`uv-cache` 1.58 GB／`pythons` 59.7 MB）。`C:\work` 之外僅剩 `.local\bin` 的 uv 三個執行檔（39 MB，是 uv 本身而非派森套件）。

### 11.5 Positron 唯一的 `C:\work` 外足跡：22 MB 位元碼快取（非安裝）

`%APPDATA%\Positron\User\globalStorage\ms-python.python\pycache\` 有 1411 個 `.pyc`、22.49 MB。已查證其性質：

| 指標 | 值 | 判讀 |
|---|---|---|
| `*.dist-info` 數 | **0** | 沒有任何已安裝套件 |
| `*.py` 原始碼數 | **0** | 沒有複製任何原始碼 |
| `*.pyc` 位元碼數 | 1411 | 純編譯快取 |
| 是否在 `sys.path` | **否**（實測 `sys.path` 無 AppData／Positron 項） | 永不會被匯入 |

**結論：這不是重疊安裝**，是 Positron 自己的環境分析快取，可隨時刪除且會自動重建。若仍希望連這 22 MB 都不落在 `C:\work` 外，唯一辦法是把 Positron 整個 user-data 目錄搬過去（`--user-data-dir C:\work\Positron\data`），但那會重置您現有的 Positron 使用者設定，故未自行變更。

### 11.6 一個會復發的外部來源（非 Positron）

清除後於 **16:46** 又有一套 cpython-3.12.15 被寫回 `%APPDATA%\uv\python`。追查結果：

- 寫入者在 **Claude 桌面應用的 MSIX 容器**內——`...\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\uv\python\` 下的 `cpython-3.12-...` 正是指向真實 `%APPDATA%\uv\python\cpython-3.12.15-...` 的符號連結。
- 來源是 **`browser-use` MCP 伺服器**（`browser-use@inline` 外掛）。它在 10.4 被停止後由用戶端自動重啟，重啟時以 uv 臨時取用 3.12，而該行程的環境未套用 `UV_PYTHON_INSTALL_DIR`，uv 便退回預設位置下載。
- **與 Positron、與您的派森環境皆無關**，但只要該外掛持續重啟就會復發。

若要徹底斷根，二選一：**重啟 Claude 桌面應用**（讓它重新繼承 `UV_PYTHON_INSTALL_DIR=C:\work\pythons`），或**停用 `browser-use` 外掛**。我已再次清除該 60.3 MB，但未代您改動外掛設定。

### 11.7 本輪結論

| 項目 | 結果 |
|---|---|
| Positron 開啟 | **PASS**（10 行程、視窗標題正確、37 擴展） |
| 解譯器探索 | **PASS**（6 個環境全被掃到，`venvPath` 生效） |
| 派森執行期 | **PASS**（核心啟動／執行／xlsx 讀寫／中日韓往返一致） |
| kernelspec | **7/7 健康**，修掉 1 個指向 0 位元組假檔的故障核心 |
| `C:\work` 外派森安裝 | **0**（釋出 7.8 GB；僅餘 Positron 22 MB 位元碼快取，非安裝） |
| 尚未重開機 | 依指示保持，WSL2 仍待生效 |

---

## 十二、2026-10-10 重開機後實測

### 12.1 WSL2 已生效

機器於 **06:52:13** 重新啟動（非本次作業觸發）。重開機後 WSL2 轉為可用：

| 檢查 | 重開機前 | 重開機後 |
|---|---|---|
| `wsl --status` | `Wsl/WSL_E_WSL_OPTIONAL_COMPONENT_REQUIRED` | **默認版本: 2** |
| `wsl --version` | 3.0.1.0（已裝未生效） | **WSL 3.0.1.0／核心 6.18.40.1-1／WSLg 1.0.79** |
| 發行版 | 0 | **0**（依指示不裝，註冊表 `Lxss` 無任何登記） |

### 12.2 Positron 重啟並驗到「實時」派森主控台

重新以本項目路徑啟動（13 個行程，主視窗 `Welcome - positron-research-profile - Positron`）。本輪取得比合成測試更直接的實證——Positron 自己的派森主控台行程正在執行中：

```
PID 32380  C:\work\envs\ds\Scripts\python.exe                        \
PID 33616  C:\work\pythons\cpython-3.13-windows-x86_64-none\python.exe
           ...\positron-python\python_files\posit\positron_language_server.py
           --session-mode=console
```

亦即 Positron 真的把主控台開在 `C:\work\envs\ds`（3.13.16）上，`venvPath` 設定與單一版本統一皆按預期運作。

### 12.3 新測項：ark（Positron 的 R 核心）端到端

Positron 的 R 主控台由 Rust 寫的 `ark` 核心驅動。以 `jupyter_client` 直接驅動 `positron-r\resources\ark\windows-x64\ark.exe`（**Ark 0.1.252+266.5564f48**）：

```
Successfully opened R shared library at 'C:\work\R\R-4.6.1\bin\x64\R.dll'
  （同時載入 Rgraphapp / Rlapack / Riconv / Rblas）
R version   : R version 4.6.1 (2026-06-24 ucrt)
R.home      : C:/work/R/R-4.6.1
.libPaths   : C:/work/R/R-4.6.1/library
openxlsx2   : 1.29
data.table  : 1.18.6.1
roundtrip   : TRUE | rows 2
RESULT: PASS — ark 核心啟動並成功執行 R
```

> 註：`positron-r` 同時內附 `windows-arm64` 與 `windows-x64` 兩套 ark，本機須用 x64 版（誤用 arm64 會回報「不是有效的應用程式」）。

### 12.4 3.12 復發，已依兩條規則清除

11.6 預判的復發確實發生。開機後時間線：

| 時間 | 事件 |
|---|---|
| 06:52:13 | 開機 |
| **06:57:22** | `C:\work\pythons\cpython-3.12.15` 被建立——Claude 應用重啟後繼承了 `UV_PYTHON_INSTALL_DIR`，uv 遂裝進 `C:\work`（重導奏效） |
| **06:58:15** | `%APPDATA%\uv\python\cpython-3.12.15` 也被建立——另一個未套用該變數的行程所為 |

查證兩者關係：`%APPDATA%` 那份是 **60.3 MB 真實目錄**（非指向 `C:\work` 的連結；同層 `cpython-3.12-...` 只是指向它的 Junction）。亦即確實存在**兩份獨立實體**。

根源已定位：`browser-use` 外掛在
`...\Claude_pzs8sxrjxfjjc\LocalCache\...\plugin_01PBVJh18JySdSHvKEhDSiQY\modelcontextprotocol\.python-version`
釘選了自己的派森版本（檔內值為 `3.11`），因此每次啟動都會讓 uv 另外取得一套解譯器。

依您訂的兩條規則處置（清除前確認無任何 uv／browser-use 行程在跑）：

| 位置 | 違反的規則 | 處置 |
|---|---|---|
| `C:\work\pythons\cpython-3.12.15` | 只保留一個派森版本 | `uv python uninstall 3.12` 已卸載 |
| `%APPDATA%\uv\python`（60.3 MB） | 不得裝在 `C:\work` 之外 | 已刪除 |

清除後 Positron 的實時主控台（PID 32380／33616）未受影響，仍正常執行。

**這會再復發。** 只要 `browser-use` 外掛被啟用，每次它啟動就會重裝一套。該外掛本身目前也處於 `CONNECT_TIMEOUT` 故障狀態。唯一能根治的辦法是在 `/plugin manage` 停用該外掛；在那之前，本報告記錄的清除指令可重複套用：

```powershell
uv python uninstall 3.12
Get-ChildItem "$env:APPDATA\uv\python" -Force | Remove-Item -Recurse -Force
```

### 12.5 重開機後完整回歸

| 項目 | 結果 |
|---|---|
| 派森堆疊（3.13.16） | polars 971 ms／fastexcel 1744 ms／calamine 223 ms／xlsx2csv 50 ms — **4/4 PASS** |
| 派森 Jupyter 核心 | **PASS**，7 個 kernelspec 全在 `C:\work`（11.3 的修正存活） |
| ark R 核心 | **PASS**（新測項，見 12.3） |
| 鄀（R）4.6.1 | openxlsx2 431/72 ms、data.table 2/8 ms — **PASS**，均往返一致 |
| 跨語言互通 | 雙向 3 項 **全 PASS** |
| uv 目錄變數 | 5 個全部存活於 `C:\work` |
| 規則一（單一版本） | **滿足**：`C:\work\pythons` 僅 3.13.16（59.7 MB），6 個環境全 3.13.16 |
| 規則二（`C:\work` 外零安裝） | **滿足**：全域掃描無任何含 `dist-info` 的 site-packages |

---

## 十三、2026-10-10 續測（同日第二輪）

### 13.1 擴展版本核對與升級

`positron --update-extensions` 回報無可更新，但對照 OpenVSX 上游仍有 7 項落後。逐一嘗試釘選安裝，查明鏡像實際擁有哪些：

| 擴展 | 本機原版 | 上游最新 | 鏡像可裝 | 結果 |
|---|---|---|---|---|
| `reditorsupport.r` | 3.0.1 | 3.1.20261009 | ✓ | **已升級** |
| `eamodio.gitlens` | 19.3.0 | 2026.10.90519 | ✓ | **已升級**（大版號跨越） |
| `anthropic.claude-code` | 2.1.295 | 2.1.296 | ✗ | 鏡像未同步 |
| `charliermarsh.ruff` | 2026.84.0 | 2026.86.0 | ✗ | 鏡像未同步 |
| `github.vscode-pull-request-github` | 0.162.0 | 0.168.0 | ✗ | 鏡像未同步 |
| `openai.chatgpt` | 26.5730.61309 | 26.5908.31748 | ✗ | 鏡像未同步 |
| `meta.pyrefly` | 1.3.1 | 1.3.9003 | ✗ | 且為預發行版，依穩定性優先不採用 |

釘選安裝留下的 2 個舊目錄（`gitlens-19.3.0`、`reditorsupport.r-3.0.1`）已依「以實際啟用版本為準」刪除。

現況：**37 個擴展／37 個目錄／0 重複／3.88 GB**；對照舊主機 **升級 13、持平 15、退化 0**。

### 13.2 `browser-use` 3.12 第三次復發——根因完全查明

開機後 07:58 又建立兩份 3.12。這次抓到確切的啟動指令：

```
uv.exe tool uvx --python 3.12 browser-use@latest --cli-mcp
```

**`--python 3.12` 是硬編碼在外掛啟動指令裡的**（不只是 `.python-version` 檔），所以它每次啟動都必然索取一套 3.12，與本機統一到 3.13.16 無關、也無法透過環境變數繞過。

兩份的角色也查清了：

| 位置 | 類型 | 是否在用 | 處置 |
|---|---|---|---|
| `C:\work\pythons\cpython-3.12.15` | 真實目錄 | **正在用**（MCP 伺服器 PID 22660 以它執行） | **暫留**（見下） |
| `%APPDATA%\uv\python\cpython-3.12.15` | 真實目錄 60.3 MB | 未使用，純重複 | **已刪** |

處置理由：
- `%APPDATA%` 那份違反「不得裝在 `C:\work` 之外」的硬禁令，且無人使用，零代價刪除——**已清零，刪除後 MCP 伺服器未受影響**。
- `C:\work` 那份雖牴觸「只保留一個版本」，但它在 `C:\work` 內（硬禁令成立），且正支撐一個運行中的工具；刪了它會立刻斷掉該工具，而外掛數分鐘內又會重裝，純屬打地鼠。故暫留並記錄。

**根治只有一途**：在 `/plugin manage` 停用 `browser-use` 外掛。在那之前每輪清理指令為：

```powershell
uv python uninstall 3.12
Get-ChildItem "$env:APPDATA\uv\python" -Force | Remove-Item -Recurse -Force
```

### 13.3 升級後回歸實測

| 項目 | 結果 |
|---|---|
| 派森堆疊（3.13.16） | polars 709 ms／fastexcel 1557 ms／calamine 227 ms／xlsx2csv 48 ms — **4/4 PASS** |
| 派森 Jupyter 核心 | **PASS**（`C:\work\envs\ds`，3.13.16） |
| ark R 核心 | **PASS**（`reditorsupport.r` 升到 3.1 後複驗，R 4.6.1／openxlsx2 1.29／data.table 1.18.6.1，往返 TRUE） |
| 鄀（R）堆疊 | openxlsx2 334/35 ms、data.table 1/8 ms — **PASS**，均往返一致 |
| 版本退化 | **0 項** |
| 規則二（`C:\work` 外零安裝） | **滿足** |

---

## 十四、2026-10-10 最優化稽核

### 14.1 最大發現：Positron 本體卡在半套用的更新狀態

稽核一開始就撞到一個矛盾：

| 來源 | 版本 |
|---|---|
| `positron --version` | 2026.09.1 build 2 |
| `C:\work\Positron\Positron.exe` 檔案版本 | 2026.09.1 |
| **登錄檔反安裝記錄** | **2026.10.0** |
| winget 倉庫最新 | 2026.10.0 |

追查後查明：**2026.10.0 已下載並暫存完畢，只差套用**。

```
C:\work\Positron\_\Positron.exe          2026.10.0  ← 暫存，共 2.23 GB，建置於 10-08
C:\work\Positron\Positron.exe            2026.09.1  ← 執行中的舊版
C:\work\Positron\tools\inno_updater.exe             ← 負責交換的更新器 (Inno Update v0.22.0)
C:\work\Positron\unins000.exe            10-10 07:01 更新  ← 新版反安裝器已就位
```

Positron 長時間開著，檔案換不掉，於是登錄檔已記成新版而二進位仍是舊版——**一個不一致的半完成狀態**。

處置：關閉 Positron 後執行 `inno_updater`，更新套用成功。

| | 之前 | 之後 |
|---|---|---|
| Positron | 2026.09.1 build 2 | **2026.10.0 build 297** |
| Code OSS | 1.130.0 | **1.134.0** |
| 安裝目錄 | 4.4 GB（含暫存） | **2.19 GB**（暫存已回收 2.23 GB） |
| 擴展 | 37 | 37（全數完好） |
| 使用者設定 | — | 全部保留（`venvPath`／`defaultInterpreterPath`／`colorTheme`） |

### 14.2 新版補上了一個原列為「無法取得」的缺口

2026.10.0 的內建擴展由 129 降為 121 個，但新增了一項對本項目策展清單有意義的：

| | 狀態變化 |
|---|---|
| `GitHub.copilot-chat@0.62.0` | **現已內建**。報告 3.2 原將 `github.copilot` 列為「微軟專有、OpenVSX 無」，此缺口由新版自行補上 |

剩餘兩項仍無（已在新版 gallery 重試確認）：`ms-python.vscode-pylance`（授權限定，由內建 `meta.pyrefly` 替代）、`plotly.plotly-vscode`（註冊表無，內建 Plots 面板覆蓋）。

逐一比對 121 個內建擴展與 37 個外部擴展的 ID：**零重疊**，故沒有任何因重複而該移除的擴展。

內建執行期組件：`ms-python.python@2026.99.0-dev`、`positron.positron-r@0.0.2`、`positron.positron-duckdb@0.0.1`、`positron.positron-supervisor@0.0.1`；ark 核心由 `0.1.252+266` 升至 **`0.1.252+355.f1af004`**。

### 14.3 執行期回歸（2026.10.0 上）

| 項目 | 結果 |
|---|---|
| 派森 Jupyter 核心 | **PASS**：3.13.16／`C:\work\envs\ds`／polars 6341 B → fastexcel (3,3) → calamine 4 列／往返 True |
| ark R 核心（新版 Ark） | **PASS**：R 4.6.1／openxlsx2 1.29／data.table 1.18.6.1／往返 TRUE |

### 14.4 容量結構——這是唯一還不算「最優」的地方

擴展總容量 3.88 GB，前五名：

| 擴展 | 容量 |
|---|---:|
| `ms-mssql.mssql` | **1032.9 MB** |
| `openai.chatgpt` | 946.5 MB |
| `kilocode.kilo-code` | 520.6 MB |
| `anthropic.claude-code` | 258.7 MB |
| `google.geminicodeassist` | 238.6 MB |

**AI 代理類合計 2425.3 MB，佔擴展總容量 61%**，分佈於 8 個外部代理（claude-code、continue、chatgpt、geminicodeassist、kilo-code、roo-cline、claude-dev、posit.assistant）**另加新內建的 Copilot Chat**，共九路功能高度重疊。

`ms-mssql.mssql` 單項 1 GB，是全場最大。它來自 `categories.json` 的 `Database` 分類，屬策展清單內項目；但本項目的資料層實際以 DuckDB／Postgres 為主，而 Positron 已內建 `positron-duckdb` 與七個 data-driver。SQL Server 客戶端在量化科研工作台是否值得 1 GB，建議使用者自行裁量。

> 此兩項**未自行移除**——`ms-mssql.mssql` 在策展清單內，九路 AI 代理則是使用者明示的多模型會商編制（見記憶 `multi-ai-consultation-method`）。純屬容量觀察，供裁決。

### 14.5 稽核結論

| 面向 | 判定 |
|---|---|
| 組件完整性 | **已最優**。策展清單 32/35 直接或內建滿足，餘 3 項皆有替代且已複查確認仍不可得 |
| 版本 | **已最優**。Positron 升至 2026.10.0；對照舊主機升級 13、持平 15、**退化 0** |
| 一致性 | **已最優**。37/37 無重複；派森單一 3.13.16；7 個 kernelspec 全在 `C:\work` |
| 設定 | **已最優**。`venvPath`／`defaultInterpreterPath` 生效並經實測；主題保留 |
| 執行期 | **已最優**。派森與 R 兩核心在新版上皆 PASS |
| 容量結構 | **尚可精簡**。61% 擴展容量花在九路重疊的 AI 代理；mssql 單項 1 GB |
| 鏡像落後 | **非本機可控**。4 項（claude-code 2.1.296、ruff 2026.86.0、PR-github 0.168.0、chatgpt 26.5908）上游有而 p3m 鏡像無，已在新版 gallery 重試確認 |

本機最終狀態：Positron 2026.10.0 build 297／Code OSS 1.134.0／37 擴展／121 內建／派森 3.13.16 單一版本 6 環境／R 4.6.1／Quarto 1.10.18／uv 0.12.23／WSL 3.0.1.0（0 發行版）。

---

## 十五、2026-10-10 第二輪稽核：容量結構與鏡像落後項

### 15.1 鏡像落後 4 項——再查，並修正一次意外退化

重查 p3m 鏡像對這 4 項的供給。鏡像的 `/latest` 端點對 `openai.chatgpt`（26.5908.31748）與 `github.vscode-pull-request-github`（0.168.0）回報有新版，看似已同步。但實測安裝端：

| 擴展 | 鏡像 `/latest` 宣稱 | 不帶版號實際裝到 | 判定 |
|---|---|---|---|
| `openai.chatgpt` | 26.5908.31748 | **26.721.30844（更舊）** | 鏡像謊報 |
| `github.vscode-pull-request-github` | 0.168.0 | 0.162.0（本機原版） | 鏡像謊報 |
| `anthropic.claude-code` | — | 鏡像仍停 2.1.295 | 無新版 |
| `charliermarsh.ruff` | — | 鏡像仍停 2026.84.0 | 無新版 |

**過程中 chatgpt 一度被裝成 26.721.30844，低於本機原有的 26.5730.61309——觸發退化。** 立即依「只升不降」鐵律釘選回裝 `26.5730.61309`，退化已消除，殘留的 26.721 目錄已刪。

結論：這 4 項**本機已無計可施**。p3m 鏡像的 `/latest` 端點與實際可安裝資產不一致（謊報新版），硬裝只會退化。非本機可控，只能待鏡像自行同步；期間**切勿**對這幾項做不帶版號的 `--install-extension`，會中退化陷阱。

最終：**退化 0**、37/37 無重複（對照舊主機仍為升級 13、持平 15、退化 0）。

### 15.2 容量結構全景（純量測，未刪任何擴展）

擴展總容量 3.98 GB，按功能分類：

| 分類 | 容量 | 佔比 |
|---|---:|---:|
| **AI 代理** | **2425.1 MB** | **61.0%** |
| **資料庫**（mssql 單項） | **1032.9 MB** | **26.0%** |
| 視覺化 | 239.9 MB | 6.0% |
| 派森 | 81.7 MB | 2.1% |
| R／科研 | 61.6 MB | 1.5% |
| Git／其他 | 55.1 MB | 1.4% |
| Jupyter | 54.7 MB | 1.4% |
| Web | 21.6 MB | 0.5% |
| 容器 | 4.2 MB | 0.1% |

**兩類即佔 87%**：

- **AI 代理 61%**——9 路功能重疊（claude-code、continue、chatgpt、geminicodeassist、kilo-code、roo-cline、claude-dev、posit.assistant，另加內建 Copilot Chat）。這是使用者明示的多模型會商編制，**按編制保留**。
- **mssql 單項 26%（1 GB）**——策展清單 `Database` 分類內項目，但本項目資料層以 DuckDB／Postgres 為主，Positron 已內建 `positron-duckdb` 加 7 個 data-driver。

**未自行移除任何一項**：AI 編制屬使用者既定方針，mssql 在策展清單內。此節純為量測，裁量權在使用者。若使用者裁定精簡，候選順序建議為：先 mssql（省 1 GB，且有內建替代），AI 代理則依實際使用頻率由使用者圈定去留。

---

## 十六、2026-10-10 移除 kilo-code 並實測無損

依先生裁示移除 kilo-code，移除前盤點、移除後實測，確認「替代無缺口」。

### 16.1 移除前盤點

| 查項 | 結果 |
|---|---|
| kilo 實際佔用 | 525 MB（擴展目錄）＋ globalStorage |
| 被其他擴展依賴？ | **否**（`extensionDependencies` 反查全空，移除不連累他者） |
| settings.json 牽連 | 4 行 kilo 專屬終端快捷（`commandsToSkipShell`），成孤兒須清 |
| 替代者基線 | Continue 2.1.0（231 MB）、Cline 4.1.23（35 MB）皆在 |

### 16.2 移除與清理（共釋約 520 MB）

- `positron --uninstall-extension kilocode.kilo-code` → 成功
- 清殘留目錄 kilo（520.6 MB）＋ globalStorage
- settings.json：移除整塊 kilo 的 `commandsToSkipShell`（已備份 `.bak-20261010c`，JSON 校驗合法）
- 順帶清掉兩筆自動升級遺留的舊版目錄：`claude-code-2.1.295`、`ruff-2026.84.0`

最終：**36 目錄 = 36 啟用，無殘留、無重複**；容量 3.88 → **3.37 GB**。

### 16.3 移除後實測——無任何缺口

| 實測項 | 結果 |
|---|---|
| 派森 Jupyter 核心 | **PASS**（3.13.16／`C:\work\envs\ds`／polars 寫、fastexcel 讀、calamine、往返 True） |
| 替代者完整性 | Continue、Cline、Claude Code、ChatGPT、Gemini **五路俱在** |
| kilo 殘留 | 擴展／目錄／globalStorage／設定 **四處皆無** |

**結論：移除 kilo-code 不造成任何局限或不足。** 其先生用得上的能力（多模式代理、MCP、行內補全）已由 Continue（補全＋多模式）＋ Cline（自主代理）完整承接，二者皆開源免費、OpenVSX 可裝、不需 worktree。kilo 的旗艦 Swarm 子代理本就因需 worktree 而與先生鐵律相斥、無法啟用，故移除它連「潛在損失」都無。淨效果：省 520 MB、少一路重疊，功能無缺。

---

## 十七、2026-10-10 共存衝突實測，與 kilo 終局移除

### 17.1 Kilo ↔ Cline／Continue 共存實測

先生裁示保留 kilo，遂重裝並實測其與既有代理的共存（四個衝突面逐一驗 package.json 的 contributes）：

| 衝突面 | Kilo ↔ **Cline** | Kilo ↔ **Continue** |
|---|---|---|
| 命令 ID 撞車 | 無 | 無 |
| 快捷鍵撞車 | **無** | **5 組**：`tab`、`ctrl+l`、`ctrl+k ctrl+a`、`ctrl+shift+r`、`escape` |
| 行內補全競爭 | 無（Cline 不做補全） | **有**（兩家都做，爭同一游標位） |
| 實際載入崩潰 | 無（重啟後兩者皆啟用，日誌無 activate 失敗） | 無（不崩潰，但補全互擾） |

**結論**：Kilo 與 Cline 潔淨共存；Kilo 與 Continue 不崩潰但在**行內補全**上真實衝突——且該功能正是 kilo 唯一勝過 Cline 的獨門，偏偏 Continue 已覆蓋。

### 17.2 「Kilo Marketplace」彈窗查證

實測確認：它**非安裝件**，是 kilo-code 擴展內建的面板（命令 `kilo-code.new.marketplaceButtonClicked` 開啟），陳列可加掛的 MCP 伺服器與自訂模式。瀏覽不下載任何東西，關閉即可。附告先生：日後若從中裝 MCP 伺服器，須經在下把目標路徑鎖進 `C:\work`（同 uv 之法），切勿直接點 Install 落入預設路徑。

### 17.3 終局移除 kilo（依先生「若無法兼容 Continue 即移除」之令）

判定：Kilo 與 Continue 在補全功能上確實衝突，且衝突處恰是 kilo 唯一不可取代之長而 Continue 已覆蓋——條件成立。移除：

- `positron --uninstall-extension kilocode.kilo-code` → 成功
- 清殘留目錄＋globalStorage＋settings.json 的孤兒 `commandsToSkipShell`（重裝時被自動補回，已再清；備份 `.bak-20261010d`）
- 最終 **36 擴展、無 kilo 殘留、JSON 合法**

**淨效果**：功能無損（Continue 補全＋Cline 代理＋Claude Code 全覆蓋）、消弭補全打架、省 520 MB。此與第十六節結論一致——以先生的硬準繩檢驗，kilo 於此工作台可汰無虞。

---

## 十八、2026-10-10 kilo 永久排除之落實（乙策）

先生裁定 kilo 完全根除，並命於鐵律與安裝清單注明、日後不納入。惟驅動安裝的 `install-positron-with-best-suit.ps1`（第 18 行 `kilocode.kilo-code`）屬受保護的既有文件。在下呈甲乙丙三策，先生取在下所薦**乙策**。落實如下：

| 動作 | 內容 |
|---|---|
| 鐵律記憶 | 新增 `excluded-components`（kilo 永久排除＋理由＋把關方式）與 `repo-existing-files-untouchable`（成文化「既有文件不改」首令） |
| 新建修正腳本 | **`install-positron-best-suit.v2.ps1`**（新增文件，不動舊檔）——剔除 kilo 的可執行安裝行，僅留注釋說明排除理由；PowerShell 解析器校驗語法合法、無可執行的 kilo 指令 |
| 舊檔 | `install-positron-with-best-suit.ps1` **原樣封存未改**，作舊主機基線史料 |

自此，日後開荒改用 v2 腳本即自動排除 kilo；縱有人誤用舊檔，`excluded-components` 記憶亦令在下執行時主動略過 kilo 那行。雙重把關。

**roo-cline 之裁示見下節。**

## 十九、2026-10-10 汰除停更化石 roo-cline

先生裁定一併汰除。盤點：roo 無任何擴展依賴、settings 無牽連（`settings.json` 內 `ROOT` 二字係 mssql 連線群組，非 roo），佔 148 MB。潔淨移除：

- `positron --uninstall-extension rooveterinaryinc.roo-cline` → 成功
- 清殘留目錄（148 MB）＋ globalStorage
- 無需動 settings.json

**實測無損**：移除後派森核心 PASS（3.13.16／往返 True）。保留的 AI 代理五路：Claude Code、Cline、Continue、ChatGPT、Gemini。

記憶 `excluded-components` 已把 roo-cline 由「建議排除待裁示」更新為「永久排除（已根除）」。

### 最終擴展狀態（本輪 AI 編制精簡總結）

| 階段 | 擴展數 | 容量 |
|---|---:|---:|
| 2026.10.0 升級後 | 37 | 3.88 GB |
| 移除 kilo-code | 36 | 3.37 GB |
| 移除 roo-cline | **35** | **3.23 GB** |

共汰除兩個化石／冗餘代理，省約 **668 MB**，功能零損失（補全＝Continue、自主代理＝Cline、對話＝Claude Code／ChatGPT／Gemini）。35 擴展、0 重複、0 殘留。

---

*本報告為新建文件。倉庫內 41 個既有文件（含 `reports/Research_Report.md`、`reports/Research_Profile.csv` 等舊主機記錄）全部保持原狀，`git status` 僅顯示本文件為未追蹤新增。*
