# Positron 研究工作台 · 遷移查證與實測報告

| 項目 | 內容 |
|---|---|
| 報告日期 | 2026-10-06（**2026-10-09 複核並更新**，見第九節） |
| 新主機 | `SHJ-H0647-RYOCH`／使用者 `PPCCpcpc` |
| 舊主機 | `PCCPPPCCC`（依 `positron已安裝的扩展列表.txt` 內殘留的提示符還原） |
| 硬體 | Intel i5-12400（6 核 12 執行緒）／31.8 GB RAM／Windows 10 Pro 19045 |
| 倉庫分支 | `世博量化研究院` @ `ba27dfc` |
| 本輪倉庫改動 | **0**（既有 41 個文件一律未改，`git diff` 為空；僅新增本報告） |
| 結論 | 組件齊備、**版本退化 0 項**、實測 **11/11 通過**（10-06 與 10-09 兩輪皆通過）；餘 1 項待您決策（WSL2） |

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

依本項目既有策展政策，這類擴展屬移除對象——`generate_remove.py` 會把它分類為 `Theme` 並寫入 `Remove.csv`，`Remove-VisualExtensions.ps1` 的硬編碼名單也正是同類主題。

**未自行刪除**：有可能是您自己挑的配色方案。若要移除：

```powershell
positron --uninstall-extension aurora-them-creator.theme-aurora-nocturne
```

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
| 7.1 WSL2 安裝 | **仍待您決策**（需管理員權限與重開機） |
| 7.2 `python.venvPath` 設定 | **仍待您決策**（涉及既有 `settings.json`） |
| 7.3 鏡像同步後補升級 | 已執行 `--update-extensions`；`openai.chatgpt` 已追上，餘 3 項鏡像尚未同步（見 3.5） |

---

*本報告為新建文件。倉庫內 41 個既有文件（含 `reports/Research_Report.md`、`reports/Research_Profile.csv` 等舊主機記錄）全部保持原狀，`git status` 僅顯示本文件為未追蹤新增。*
