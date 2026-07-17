# shared/scripts — 產出驗證與匯出工具

各 skill 共用的工具鏈。來源標注：`verify.py`（改寫）、`export_deck_*.mjs`／`html2pptx.js`／`render-video*.js`／`convert-formats.sh`／`../assets/animations.jsx`（原樣搬運）、`html2pdf.mjs`（改寫）皆出自 [huashu-design](https://github.com/alchaincyf/huashu-design)（alchaincyf，MIT License）。

## 安裝依賴（一次性）

```bash
# 驗證用（Python）
pip3 install --user playwright && python3 -m playwright install chromium

# 匯出用（Node，於本目錄執行）
npm install

# 影片導出另需 ffmpeg 在 PATH 上（macOS：brew install ffmpeg）
```

## 工具清單

| 檔案 | 用途 | 何時用 |
|---|---|---|
| `verify.py` | 打開 HTML → 截圖 → 抓 console/page error | **每份 HTML 產出交付前必跑**（pm-propose／pm-prototype 的「產出驗證」步驟） |
| `html2pdf.mjs` | 單一 HTML（report/BRD/PRD 長頁）→ 向量 PDF | 使用者要傳閱/列印版時：`node html2pdf.mjs --in x.html --out x.pdf`（預設 A4 分頁；`--single` 出一張等高長頁） |
| `export_deck_pdf.mjs` | 多檔 slide deck 目錄 → 合併向量 PDF | 未來做 pitch deck（每頁獨立 HTML）時 |
| `export_deck_pptx.mjs` + `html2pptx.js` | 多檔 slide deck → **可編輯** PPTX（原生文字框） | 未來做 pitch deck 且對方要能改字時。⚠️ HTML 必須符合上游的 4 條硬約束（頁面 960×540pt 比例、文字必須包在 `<p>/<h*>` 標籤、避免漸變、避免複雜疊層）——不符合就走 PDF 路徑，**不要為了遷就轉檔而降級 HTML 設計** |
| `render-video.js` | 動畫 HTML → MP4（Playwright recordVideo，25fps） | pm-demo 的預設導出：`node render-video.js demo.html --duration=30`。動畫 HTML 需設 `window.__ready`（用 `../assets/animations.jsx` 的 Stage 會自動處理）；需要 ffmpeg |
| `render-video-seek.js` | 動畫 HTML → 真 60fps／確定性 MP4（逐幀 seek 截圖） | 高品質交付時：`node render-video-seek.js demo.html --fps=60`。前提：動畫走 animations.jsx 的 Stage 時鐘（響應 `window.__seekRender`）；需要 ffmpeg |
| `convert-formats.sh` | MP4 → 60fps MP4 + palette 優化 GIF | 要 GIF（Slack/README 預覽）或 60fps 標籤時：`bash convert-formats.sh demo.mp4`。⚠️ `--minterpolate` 插幀模式在 macOS QuickTime 有相容性問題，交付前必須本地測 |
| `../assets/animations.jsx` | 時間軸動畫引擎（Stage/Sprite/useTime/useSprite/Easing/interpolate，仿 Remotion 零依賴） | pm-demo 產動畫 HTML 時 inline 進 `<script type="text/babel">`。依賴 pinned CDN 的 React 18.3.1 + Babel standalone 7.29.0（動畫 HTML 是中間工作檔，MP4 才是交付物，故允許外連） |

## 注意

- deck 兩條鏈（`export_deck_*`）目前沒有 skill 使用，是為未來 pitch deck skill 預先搬運的——V1 的 pm-propose report 是單頁 HTML，只用 `html2pdf.mjs`。
- `node_modules/` 不入版控；換機器重跑 `npm install` 即可。
