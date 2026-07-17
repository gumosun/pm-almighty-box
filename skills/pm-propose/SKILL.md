---
name: pm-propose
description: 提案文件組——吃進一個已決定的 initiative + 公司脈絡包，輸出 BRD→PRD（雙版本：人讀 HTML + AI 開發 md）+ 一份可簡報的 HTML report，全部套公司 CI。用於把決定好的東西向 stakeholder/CEO/開發提案。
---

# pm-propose — 提案文件組

## Overview

這個 skill 回答「這個已經決定要做的功能，怎麼變成一套能實際拿去對人提案/開發的文件」。輸入是一個**已經決定要做**的 initiative（不評估該不該做——那是 `pm-assess` 的範疇，這裡可以承接它的產出，但不強制要求），輸出是三份文件：

1. **BRD**（Business Requirements Document）——給跨部門 stakeholders：為什麼做、對誰有影響、成功長怎樣，並且對照 `stakeholders.md` 講清楚各方在意/擔心什麼。
2. **PRD**（Product Requirements Document）——給工程/設計：使用者流程、功能邏輯、邊界條件、驗收標準，產**兩個版本**：人讀 HTML + AI 開發用 md。
3. **簡報用 HTML report**——濃縮 BRD+PRD 精華，套公司 CI，可以直接對主管/CEO 過。

三段依序進行（BRD → PRD → report），但**每段結尾都要問「繼續下一段還是先停」**，不自動一路跑完（silo）。這是一個持續被呼叫的工具，不是一次性跑完就結束的批次流程。

**核心原則：脈絡（誰在意什麼、公司長怎樣）來自 context pack，不臆測；CI 一律從 `brand-tokens.css` 讀變數，不自創顏色。**

## Step 0 — 讀取脈絡包

在動筆之前，先讀這四份檔案：

```
contexts/<company>/product.md
contexts/<company>/brand-voice.md
contexts/<company>/brand-tokens.css
contexts/<company>/stakeholders.md
```

- 如果不知道是哪間公司或路徑，**先問**：「這次要提案的是哪間公司？脈絡包路徑是？」不要預設任何特定公司資料夾。
- `brand-tokens.css` 缺檔尤其致命——沒有它就沒有 CI 依據，HTML 產出會變成自由發揮，失去這個工具「套公司 CI」的意義。缺檔就停下來問要不要先補上再繼續。
- `stakeholders.md` 缺檔則說清楚：BRD 和 report 的「對照各方在意點」會退化成泛用模板，問要不要先補（或先接受這個限制往下做）。
- 若使用者提供了 `pm-assess` 的產出（決策評估文件）或其他既有研究，讀進來當背景，但**不要求一定要有**——沒有就直接進 Step 1 問清楚。

## Step 1 — 確認 Initiative

如果使用者的請求已經講清楚就不用重問，直接複述你的理解讓對方確認；沒講清楚就問：

- 功能名稱與一句話描述
- 背景：為什麼現在做？（連結 `product.md` 的策略脈絡，或使用者提供的 `pm-assess` 結論）
- 目標使用者是誰
- 有沒有已有的研究/評估文件可以參考

---

## CI 嚴格模式（三段 HTML 輸出共用）

BRD、PRD 的 HTML 版、report，三份 HTML 一律遵守以下規則，**並套用共用工藝守則 `../shared/html-craft.md`**（repo 內為 `skills/shared/html-craft.md`，裝機後為 `~/.claude/skills/shared/html-craft.md`——字重層次、空間三數量級、單一 accent 紀律、反 AI slop 黑名單、密度對比都在那裡，動筆前先讀）：

- **顏色與字型只能來自 `brand-tokens.css` 定義的 CSS variables**（例如主色、深色、文字色、背景色、邊框色、中英文字型變數——實際變數名稱與值以該公司檔案為準，不要套用任何寫死在這份 skill 裡的色碼）。不自創任何未定義的顏色。
- 若 `brand-voice.md` 或 `brand-tokens.css` 有明講「禁用舊色」或「衝突色」，嚴格遵守不使用，即使畫面上看起來很想用。
- 若 `brand-voice.md` 有「設計模式」表（例如 heading 邊框粗細、表格 header 底色、卡片樣式、字級規範），優先套用該表的具體規則；沒有的話，依 `../shared/html-craft.md` 的工藝守則排版（字重做層次、間距分三個數量級、主色當 accent 克制使用），不要發明花俏樣式，也不要退回「什麼都均一」的模板排版。
- 三份 HTML **自包含**（`<style>` 內把 tokens 的 `:root` 變數複製進去，不外連任何樣式表/字型以外的資源），不依賴任何舊專案的 slide/deck 模板檔——公司換了，模板也該完全從這公司的 tokens 重新長出來。
- 語氣依 `brand-voice.md` 的「語氣」段落調整用詞（例如正式/直接程度、術語保留慣例）。
- **顏色自審（每份 HTML 都要做）**：產出每一份 HTML 後，列出出現的所有 `#hex` 值，逐一比對是否都能在 `brand-tokens.css` 的 `:root` 變數或 `brand-voice.md` 的「設計模式 / 圖表顏色」表中找到來源。任何找不到來源的顏色（即使只是裝飾性漸層的中間色）都必須刪除或改用既有 token 表達——不接受任何新配色。

## 產出驗證（每份 HTML 交付前必做）

HTML 寫完 ≠ 做完。每份 HTML（BRD／PRD HTML 版／report）交付前必須**實際渲染並看過**：

1. 跑驗證 script（在本 skill 目錄的上一層 `shared/scripts/verify.py`；repo 內為 `skills/shared/scripts/verify.py`，裝機後為 `~/.claude/skills/shared/scripts/verify.py`）：
   ```bash
   python3 <shared>/scripts/verify.py "<輸出檔路徑>"
   ```
   它會用 Playwright 打開檔案、截圖（存到輸出檔旁的 `screenshots/`）、抓 console/page error。
2. **Page errors 必須為 0**——有 JS 錯誤就修掉重跑。
3. **用 Read 工具打開截圖，肉眼檢查**：版面沒破、視覺層次如預期（標題/表格/卡片的階層一眼可辨）、CI 顏色正確、表格沒有溢出或擠壓。同時對著截圖回答 `../shared/html-craft.md` 第 10 節的四題 craft 自檢（視覺決定來自內容哪裡／密度對比在哪／accent 出現在哪幾處／120% 細節是哪個）——答不出來就回去改，不是照樣交付。發現問題就修，修完重跑驗證。
4. 驗證通過後，在交付訊息附一句驗證結果（例如「已渲染驗證：無 JS 錯誤，截圖已確認版面正常」）。

**降級**：若環境沒有 playwright（script 會明確報錯），不要假裝驗證過——明講「本次未經渲染驗證」，並請對方用瀏覽器開啟確認。

---

## 段落 A — BRD

### Step A1 — 確認 BRD 專屬輸入
若還沒有就問：業務目標的量化依據（連結哪個指標）、範圍邊界（哪些明確不做）、已知風險與假設。

### Step A2 — 產出 BRD 內容

```markdown
# BRD：[功能名稱]
版本：v1.0
日期：[今天日期]

## 背景與動機
[2-3 句：為什麼現在做，連結 product.md 的策略脈絡或 pm-assess 的結論]

## 目標
- 業務目標：[對應哪個指標、預期方向]
- 使用者目標：[解決什麼問題，對誰]

## 範圍
**包含：**
- [邊界一]

**不包含（本次）：**
- [明確排除項目]

## 成功指標
| 指標 | 現況 baseline | 目標 | 時間框架 |
|---|---|---|---|

## Stakeholder 對照（依 stakeholders.md）
對 `stakeholders.md` 列出的每一方，明確寫出這個功能對他們的意義，不是套用同一套說法打天下：

| 對象 | 他最在意什麼（來自 stakeholders.md） | 這個功能怎麼回應 | 他最怕聽到什麼，這份提案怎麼避開/正面處理 |
|---|---|---|---|

## 風險與假設
**主要假設：**
- [假設一]

**已知風險：**
- [風險一]

## 時程概估
- 設計 / 開發 / 測試 / 上線目標

## 待決策事項（Open Questions）
- [ ] [需要決策的問題]
```

**Stakeholder 對照表是 BRD 的核心差異化部分**——不要只是列出部門名稱再寫空話，每一行都要能回答「如果只給這個人看這一段，他會不會覺得『這份文件有考慮到我』」。如果 `stakeholders.md` 某方資訊還是起草版（標了「⚠️」補實記號，例如「⚠️ …補實」），對應那一行的判斷要更保守，並在文件中註記「這方的意見依現有粗略資訊推測，建議提案前跟本人確認」。

### Step A3 — 套 CI 產出 BRD HTML

依「CI 嚴格模式」把上面內容渲染成一份自包含 HTML（標題、章節、表格、Stakeholder 對照表用清楚的視覺區隔），存至 `contexts/<company>/outputs/<日期>-<功能slug>-brd.html`。

### Step A4 — 詢問後續

「BRD 完成了。接下來要做什麼？
1. 繼續做 PRD（給工程/設計的功能規格）
2. 先停在這裡，我要先跟人對過 BRD 再說」

不管回答什麼都不要自動往下跑；等對方明確要求再進段落 B。

---

## 段落 B — PRD

可以接段落 A 的 BRD 當輸入，也可以獨立呼叫（例如 BRD 已經在別處對齊過，只需要 PRD）。

### Step B1 — 確認 PRD 專屬輸入
若還沒有就問：主要使用者流程（用戶怎麼觸發、做什麼、看到什麼）、有沒有設計稿或特定 UI 要求、已知的技術限制。

### Step B2 — 產出 PRD 內容（先定稿內容，再產雙版本）

```markdown
# PRD：[功能名稱]
版本：v1.0
日期：[今天日期]

## 功能概述
[一段話：功能目的與核心價值]

## 使用者故事
- 作為一個 [角色]，我希望能 [做什麼]，這樣我就可以 [達到什麼目的]

## 使用者流程
1. [步驟一：使用者看到什麼、做什麼]
2. [步驟二]
3. [步驟三]

## 功能規格

### [模組一]
- **行為：** [描述]
- **邊界條件：** [例外情況怎麼處理]
- **驗收標準：** [怎樣算做對了]

### [模組二]
（重複以上結構，每個模組都要有這三項，不能只寫行為沒寫邊界條件）

## 不在本次範圍
- [明確排除項目]

## 技術備注
[已知技術限制、依賴、需要工程特別注意的地方]

## 驗收測試清單
- [ ] [測試項目一]
- [ ] [測試項目二]
```

### Step B3 — 收尾前一致性自我檢查

在產出雙版本之前，對照 BRD（如有）快速檢查一次：
- PRD 的使用者故事，跟 BRD 的目標使用者是同一群人嗎？
- PRD 的功能範圍，剛好對應 BRD 描述的問題，還是明顯過度複雜或漏了 BRD 提到但這裡沒處理的部分？
- BRD 列的風險/假設，PRD 的邊界條件或技術備注裡有沒有對應處理，還是完全沒被提到？

發現不一致，直接在 PRD 裡用一句話標註（例如「⚠️ 與 BRD 範圍不完全一致：BRD 提到 X 但本 PRD 未涵蓋，需確認是否為刻意排除」），不要默默改掉 BRD 或默默忽略。

### Step B4 — 產出兩個版本

兩版內容一致，但**用途不同、寫法不同**，不是同一份稿簡單轉檔：

**版本一：人讀 HTML**
依「CI 嚴格模式」渲染，重點是可讀性與視覺層次（章節分明、流程用編號視覺化呈現、模組規格用卡片或清楚分隔），存至 `contexts/<company>/outputs/<日期>-<功能slug>-prd.html`。

**版本二：AI 開發用 md**
- 純 markdown，不套 CI 樣式（給人讀的視覺留給 HTML 版）。
- 比 HTML 版更**密、更窮舉**：每個模組的「邊界條件」要盡量列全（不是舉一個例子就好），「驗收標準」全部寫成可勾選的 checklist，能講清楚的地方用條列不用長句子。
- 目的是讓工程或開發用的 AI agent 可以直接拿這份當實作依據，不需要再回頭問「這裡沒講清楚的話要怎麼處理」——如果 Step B1 的資訊不足以窮舉某個邊界條件，在該處明講「⚠️ 待確認：[具體問題]」，不要編一個看起來合理但沒人確認過的答案。
- 存至 `contexts/<company>/outputs/<日期>-<功能slug>-prd.md`。

### Step B5 — 詢問後續

「PRD 完成了（HTML + md 兩版都在）。接下來要做什麼？
1. 繼續做簡報用的 HTML report
2. 先停在這裡」

同樣不自動往下跑。

---

## 段落 C — 簡報用 HTML Report

可以接段落 A/B 的產出，也可以獨立呼叫（例如 BRD/PRD 已經在別處定案，只需要一份給主管看的濃縮版）。

### Step C1 — 確認受眾與核心訊息
問清楚：這份 report 主要要拿給誰看（對照 `stakeholders.md` 決定開頭論點順序和用詞）、有沒有已知一定要講的核心結論。

### Step C2 — 產出內容
把 BRD 的「為什麼做／目標／成功指標」與 PRD 的「怎麼做／範圍」濃縮成一份單頁式（可捲動）report，而不是逐字複製兩份文件。建議結構：

- 一句話定位（這個功能是什麼、為什麼現在做）
- 目標與成功指標（濃縮 BRD）
- 範圍與使用者流程重點（濃縮 PRD，不需要模組級別細節）
- 依受眾（Step C1）客製的重點段——針對主要受眾最在意的點放前面、最怕聽到的疑慮主動回應
- 時程與待決策事項
- Next steps / asks（明確要對方做什麼決定或配合什麼）

### Step C3 — 套 CI 產出 HTML

依「CI 嚴格模式」渲染，這份是三份輸出裡最需要視覺層次的（畢竟是拿去對人簡報），但仍然只能用 tokens 定義的顏色/字型，不引入額外裝飾或未定義樣式。

**版面走法拿不定、或對方想比較不同方向時**：走 `../shared/variations.md`（三版真實視覺讓對方選，不丟文字選擇題）。方向清楚就單版做到好，不要沒事跑三版。

**視覺母題自檢（report 專屬，比其他兩份 HTML 更嚴）**：這份 report 的版面重心必須從**這次的內容**長出來，不是固定模板換字。動筆前先回答：「這次提案最需要被看見的一個東西是什麼？」（可能是一個排序結論、一條因果鏈、一組對比數字、一個時程），然後讓它成為版面上最有分量的視覺元素。交付時在訊息裡寫一句「這份 report 的視覺重心是 X，因為這次的核心是 Y」——寫不出來＝在套模板，回去重排。

存至 `contexts/<company>/outputs/<日期>-<功能slug>-report.html`。

### Step C4 — 結束（含可選 PDF 匯出）

這是最後一段，產出後直接問：「Report 完成了。這套 BRD/PRD/report 需要針對哪個部分再調整嗎，還是先這樣？另外需不需要 PDF 版（傳閱/列印用）？」對方若要深度質檢任一份 HTML（「這樣好不好」「幫我 review」），走 `../shared/critique.md` 的 5+1 維度評審。

若對方要 PDF，用共用 script 匯出（向量文字、可搜尋，顏色與瀏覽器所見一致）：

```bash
node <shared>/scripts/html2pdf.mjs --in "<report.html>" --out "<report.pdf>"          # A4 分頁（預設）
node <shared>/scripts/html2pdf.mjs --in "<report.html>" --out "<report.pdf>" --single # 螢幕閱讀用長頁
```

（`<shared>` 為本 skill 目錄的上一層 `shared/`；依賴安裝見 `shared/scripts/README.md`。BRD/PRD 的 HTML 版如需 PDF 也用同一個 script。）可編輯 PPTX 屬於 deck 形態的產出，本 skill 的單頁 report 不適用——對方若要「能改字的簡報檔」，明講這需要先把內容重排成 deck，屬於另一次任務。

---

## 輸出檔案總覽

一輪完整流程（若三段都跑）會產出：
```
contexts/<company>/outputs/<日期>-<功能slug>-brd.html
contexts/<company>/outputs/<日期>-<功能slug>-prd.html
contexts/<company>/outputs/<日期>-<功能slug>-prd.md
contexts/<company>/outputs/<日期>-<功能slug>-report.html
```
只跑了其中一兩段就先停，也完全正常——這是這個 skill 的預期用法，silo 不代表每次都要三段跑完。
