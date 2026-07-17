---
name: pm-demo
description: Demo 影片產生器——吃 prototype HTML 或一組產品畫面截圖 + 公司 brand-tokens，輸出 30-60 秒套公司 CI 的 MP4 demo 動畫（可選 GIF）。用於把功能變成能對 CEO/stakeholder/對外快速展示的影片，比靜態 prototype 更有說服力。
---

# pm-demo — Demo 影片產生器

## Overview

這個 skill 回答「這個功能/流程，怎麼變成一支 30-60 秒、能直接播給人看的 demo 影片」。輸入是畫面素材（`pm-prototype` 產的 HTML、現成截圖、或真實產品截圖）+ 一段功能描述，輸出是**一支 1920×1080 的 MP4**（無聲；可選派生 GIF），開場定位 → 逐屏 walkthrough → 收尾，全程套公司 CI。

**定位**：溝通工具，不是宣傳片。目標是讓看的人 30 秒內明白「這個功能是什麼、怎麼用、為什麼好」——節奏清楚優先於動畫炫技。**無聲是刻意的**：內部會議、視訊分享、Slack 傳閱都是靜音場景；要配音/配樂屬於另一次任務，明講不在本 skill 範圍。

silo skill：只做 demo 影片，不自動接其他 skill。可以吃 `pm-prototype` 的產出當素材，但不要求一定要有。

動畫工具鏈與方法論改編自 [huashu-design](https://github.com/alchaincyf/huashu-design)（MIT）；引擎與導出 script 在本 skill 目錄的上一層 `shared/`（repo 內 `skills/shared/`，裝機後 `~/.claude/skills/shared/`，下文以 `<shared>` 代稱）。

## Step 0 — 讀取脈絡包

先讀：

```
contexts/<company>/product.md
contexts/<company>/brand-tokens.css
```

- 不知道是哪間公司或路徑，**先問**。不預設任何公司資料夾。
- `brand-tokens.css` 缺檔致命——demo 影片是拿出去見人的東西，沒有 CI 依據就停下來問，不用猜測的顏色頂替。

## Step 1 — 確認素材與敘事

問清楚（已講清楚的不重問，複述確認即可）：

1. **素材是什麼？**
   - `pm-prototype` 產的 HTML → 用 Playwright 對每個 `.screen` 逐一截圖當素材
   - 現成截圖/真實產品畫面 → 收檔案，確認解析度夠（寬 ≥750px 為佳，模糊素材放大到 1080p 會毀掉整支影片的可信度）
   - **素材不足就停下來要**——影片是展示物，「誠實 placeholder」在影片裡不成立，畫面缺角就先補素材再做
2. **給誰看、什麼場合？** 內部對齊（節奏可快、術語可多）還是對外展示（節奏放慢、文案更白話）？投影/視訊播放 → 文字要更大（觀眾距離遠）
3. **時長**：預設 30 秒；素材多可到 60 秒，超過 60 秒先問是不是該拆兩支
4. **輸出格式**：MP4 預設；要不要順便出 GIF（Slack/文件內嵌預覽用）

## Step 2 — 時間軸先行（先寫時間軸，再寫任何組件）

demo 影片的失敗模式是「堆動畫」——畫面一直在動但沒有敘事。**先把時間軸表寫出來跟對方對齊**，再動手寫 code：

```
0.0 – 3.5s   開場 title card：功能名稱 + 一句話定位（套 CI）
3.5 – 9.0s   畫面 1（入口）：截圖進場 → 停留 → 標注「用戶從這裡進入」
9.0 – 15.0s  畫面 2（設定）：…
…
N-4 – N s    收尾：價值一句話 + next step（或公司名）
```

節奏規則（硬性）：

- **每段文字在畫面上停留 ≥3 秒**（讀不完的文字等於沒有）
- **每個畫面停留 ≥2.5 秒**再切換；一個時間點只有一個焦點（新元素進場時舊焦點要讓位）
- **phase 之間不做「整頁 fade 切換」的 PPT 感**——用位移/縮放讓前後畫面有空間關係（例如畫面 1 往左滑出、畫面 2 從右進場，或鏡頭從全景 zoom 到局部）
- 開場與收尾必須套 CI 的 title card（背景/文字用 tokens 的深色與主色），這是影片的品牌簽名
- 標注文字寫「這一步發生什麼」，不寫功能規格；文案語氣依受眾（Step 1）調整

## Step 3 — 產出動畫 HTML（中間工作檔）

### 架構

- 用 `<shared>/assets/animations.jsx` 的時間軸引擎：`<Stage duration={N} width={1920} height={1080}>` + 每個時間段一個 `<Sprite start={..} end={..}>`；進度用 `useSprite()` + `interpolate()` 驅動
- **例外條款——這份 HTML 允許外連**：動畫 HTML 是中間工作檔（交付物是 MP4），需要 pinned CDN 的 React/Babel 才能跑 JSX。只准用這三行（版本與 integrity 都不可改動）：
  ```html
  <script src="https://unpkg.com/react@18.3.1/umd/react.development.js" integrity="sha384-hD6/rw4ppMLGNu3tX5cjIb+uRZ7UkRJ6BPkLpg4hAu/6onKUg4lLsHAs9EBPT82L" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.development.js" integrity="sha384-u6aeetuaXnQ38mYT8rp6sbXaQe3NL9t+IBXmnYxwkUI2Hw4bsp2Wvmx4yRQF1uAm" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/@babel/standalone@7.29.0/babel.min.js" integrity="sha384-m08KidiNqLdpJqLq95G/LEi8Qvjl/xUYll3QILypMoQ65QorJ9Lvtp2RXYGBFj1y" crossorigin="anonymous"></script>
  ```
  animations.jsx 的內容直接 inline 進一個 `<script type="text/babel">`，截圖素材放同目錄用相對路徑引用。渲染 MP4 時需要網路（CDN）。
- **其他一切輸出（MP4 裡看得到的畫面）遵守 CI 嚴格模式**：顏色/字型只用 `brand-tokens.css` 的值（inline 成 CSS variables 或 JS 常數皆可，但值必須可溯源）；文字排印遵守 `<shared>/html-craft.md`（字重層次、單一 accent、反 slop——尤其不要給截圖加漸變光暈、不要 emoji 標注）

### 技術紅線（違反必炸，來自上游實測）

1. **不要手寫 Stage/播放器**——用 animations.jsx 的 `<Stage>`，它已處理 `window.__ready`（導出對時）與 `window.__recording`（錄製時強制不 loop）、`window.__seekRender`（逐幀渲染）三個信號；手寫漏掉任何一個，導出就會黑幀/錄到第二輪/無法 seek
2. style 常數命名唯一（`const introStyles = {...}`），不要都叫 `styles`——多組件命名衝突會炸
3. 禁用 `scrollIntoView`
4. easing 紀律：入場用 `Easing.easeOut`/`expoOut`（快啟動慢煞車），出場用 `easeIn`；不要全程 linear（廉價感的主要來源）

### 存檔

工作目錄一個資料夾全裝：

```
contexts/<company>/outputs/<日期>-<功能slug>-demo/
├── demo.html          # 動畫工作檔
├── screens/           # 截圖素材
└── demo.mp4           # 最終交付物（Step 4 產生）
```

## Step 4 — 驗證與導出

1. **先驗 HTML**：跑 `python3 <shared>/scripts/verify.py demo.html --wait 4000`——console/page error 必須為 0，截圖確認開場畫面正常（Stage 自帶的底部播放器條在錄製時會自動隱藏，不用處理）
2. **導出 MP4**：
   ```bash
   node <shared>/scripts/render-video.js demo.html --duration=<N>
   ```
   （高品質需求——對外展示、想要真 60fps——改用 `render-video-seek.js --fps=60`，較慢但逐幀確定）
3. **抽幀肉眼審**（對影片做，不是對 HTML 做）：
   ```bash
   ffmpeg -y -i demo.mp4 -vf "select='eq(n,25)+eq(n,<中段幀>)+eq(n,<結尾幀>)'" -fps_mode passthrough f%d.png
   ```
   （25fps 下幀號 = 秒數 × 25；開場抽 n=25 即第 1 秒，避開 t=0 可能的入場空白）
   用 Read 看開場/中段/收尾三幀：CI 顏色對、文字大小在投影距離讀得清、截圖清晰不變形、沒有 slop 元素。有問題回 Step 3 修，重新導出
4. `ffprobe` 確認時長與解析度符合 Step 1 的約定
5. **可選 GIF**：`bash <shared>/scripts/convert-formats.sh demo.mp4`（同時派生 60fps 版；GIF 預設 960 寬）

**降級**：無 playwright/ffmpeg 時不硬撐——交付 `demo.html` 並明講「環境缺 X 無法出 MP4，這份 HTML 用瀏覽器打開可直接播放（自帶播放控制條）」，附依賴安裝指引（`<shared>/scripts/README.md`）。

## Step 5 — 詢問後續

「Demo 影片完成了（[N] 秒，MP4[ + GIF]）。接下來要做什麼？
1. 調整節奏/文案/某段畫面
2. 先停在這裡，我要先拿去播」

不自動接其他 skill；對方若要配音/配樂版，明講這需要另外的音訊管線，目前不在範圍內，可以列入之後的擴充。
