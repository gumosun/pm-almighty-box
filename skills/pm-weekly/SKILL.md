---
name: pm-weekly
description: 週報產生器——吃手打的 done/doing/blocked bullets + 公司脈絡包，自動掃描本週足跡（recap/決議/產出）補漏，輸出對受眾客製、可直接貼訊息的週報（預設純文字；可選套 CI 的 HTML 正式版）。
---

# pm-weekly — 週報產生器

## Overview

這個 skill 回答「這週的週報怎麼十分鐘內發出去，而且不漏掉本週真的發生過的事」。輸入是手打的 done/doing/blocked bullets（可以很亂），skill 同時掃描 context pack 的本週足跡（新 recap、新決議、新產出）提醒補漏；輸出**預設是可直接貼進訊息軟體的純文字**、對受眾客製；使用者明講要正式版時，才用同一份內容源產套 CI 的單頁 HTML。

**核心原則：週報的數字只來自 metrics.md 或使用者的 bullets；足跡掃描只提醒、不擅自寫入——口頭發生的事只有使用者知道，週報失真比漏寫更糟。**

silo skill：只產週報，不自動接其他 skill。

## Step 0 — 讀取脈絡包

```
contexts/<company>/brand-voice.md
contexts/<company>/stakeholders.md
contexts/<company>/metrics.md
contexts/<company>/decisions.md   ← 若存在才讀（足跡掃描用）
contexts/<company>/outputs/       ← 掃描區間內的新檔案（足跡掃描用）
```

- 如果不知道是哪間公司或路徑，**先問**，不預設任何特定公司資料夾。
- `brand-voice.md` 缺檔 → 明講「語氣會退化成通用專業體」，問要不要續跑。
- `stakeholders.md` 缺檔 → 明講「受眾客製會退化」，問要先補還是接受限制續跑。
- `metrics.md` 依既有資料敏感度紀律：標注更新時間超過一季即視為不可信，引用時標「需驗證」。
- `brand-tokens.css` 只有走 Step 4 HTML 版才需要。

## Step 1 — 確認基本盤

- **日期區間**：預設本週一到今天，可改。
- **發給誰**：對照 `stakeholders.md` 確認受眾——給 CEO/主管：重點是指標、風險、要對方做的決定；給團隊：重點是進度、依賴、下週安排。受眾沒講就問，不要兩邊通吃寫成流水帳。
- 收 bullets：done / doing / blocked，格式不拘。

## Step 2 — 足跡掃描與確認

掃描區間內的 pack 足跡：

- `outputs/` 裡檔名日期落在區間內的檔案（recap、prototype、BRD/PRD、report、demo…）
- `decisions.md` 裡條目日期（`## <YYYY-MM-DD>・…`）落在區間內的新決議

跟 bullets 比對後，列出「**本週足跡——這些你沒寫，但本週有發生，要納入嗎？**」清單讓使用者勾選。**只提醒、不擅自寫入**；使用者勾了才合併進素材。沒有足跡就跳過這步，不硬列。

## Step 3 — 產出（預設純文字版）

結構（重點順序按 Step 1 的受眾客製）：

- **開頭一句話**：本週最重要的一件事——最大進展或最大風險，不是流水帳第一條
- **進度**（done）：連結到目標/指標（「上線了 X，對應 metrics 的 Y」），不是任務清單搬運
- **進行中**（doing）：附預計節點
- **卡住的**（blocked）：**明講需要收件人做什麼決定、給什麼資源**——這一區是週報存在的理由，不許寫成「持續努力中」
- 長度上限：訊息軟體一屏半內讀完；語氣按 `brand-voice.md`
- 數字紀律：只用 metrics.md 或 bullets 裡的數字；沒有就不放，不生「進度 80%」這種感覺數字

存至 `contexts/<company>/outputs/<日期>-weekly.md`，同時把可直接貼的純文字放在回覆裡。

## Step 4 — 可選 CI HTML 正式版（明講才產）

使用者說「要正式版／存檔版／給大會用」時，用同一份內容源重排成套 CI 的單頁 HTML：

- CI 嚴格模式：顏色字型只來自 `brand-tokens.css`（`:root` 變數整段複製、元素用 `var(--xxx)`、產出後 hex 溯源自審）；缺檔停下來問，不用猜測顏色頂替
- 套 `../shared/html-craft.md` 工藝守則（字重層次、密度對比、單 accent、craft 四題自檢）
- 跑 `../shared/scripts/verify.py`：page errors = 0、用 Read 看截圖肉眼審；無 playwright 明講未驗證
- 存至 `contexts/<company>/outputs/<日期>-weekly.html`；要 PDF 用 `../shared/scripts/html2pdf.mjs`

## Step 5 — 詢問後續

「週報完成（純文字已可直接貼[，HTML 版已產]）。要調整哪段，還是先這樣？」不自動接其他 skill。
