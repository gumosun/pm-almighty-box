# prototype-craft.md — Demo 級 Prototype 工藝守則

`pm-prototype` 的 **demo 級模式**（預設）專用守則，疊加在 `html-craft.md` 之上（那份管所有 HTML 的排版底線，這份管「prototype 怎麼做到能拿去 demo 現場」）。wireframe 快速模式不適用本檔。

> 方法論蒸餾自 [huashu-design](https://github.com/alchaincyf/huashu-design)（alchaincyf，MIT License）的 app-prototype 守則，依 pm-almighty-box 的定位（企業內部 PM 溝通、CI 鎖定、單檔自包含）改寫。核心立場借他一句話：**「app 原型是 demo 現場，靜態擺拍和米白佔位卡沒有說服力。」**

## 1. 交付形態：預設「平鋪主屏 + 每屏可交互」，不問二選一

demo 級的預設交付形態只有一種，**不要問使用者「要平鋪還是可操作」**——兩個好處一次給齊：

| 維度 | 預設做法 |
|---|---|
| 屏數 | 平鋪 **4-6 個主畫面**（覆蓋功能的核心面，不是隨便挑幾個）。流程超過 6 屏就抓最主要的 4-6 屏，其餘讓單屏內的按鈕/導航可以到達 |
| 布局 | 多台手機外框橫向並排（`display:flex; gap:32px; flex-wrap:wrap; align-items:flex-start`），每台上方一行小字標注這是哪個畫面、對應流程哪一步 |
| 每台交互 | **每台是獨立的迷你狀態機**：畫面內按鈕可點、能切畫面、能彈 modal、開關能 toggle——不是靜態擺拍。平鋪給全貌，點擊給縱深 |

**只有兩種情況偏離預設**（使用者明講才走）：
- 明講「只要靜態看 layout / 不用能點」→ 純靜態平鋪
- 明講「只演示一條流程走到底」→ 單台走完整 flow（此時逐屏點擊）

## 2. 每台手機 = 一個 vanilla 迷你狀態機

維持自包含鐵律：**不用 React/Babel CDN**（那是 pm-demo 動畫中間產物的專屬例外），用 vanilla JS 做到同等交互。骨架模式：

```html
<!-- 每台手機：data-initial 指定初始畫面；內部多個 .screen 疊在 .pf-content 裡 -->
<div class="pf-wrapper phone" data-initial="home">
  <div class="pf-screen"> …status bar / island / home indicator（來自 phone-frame）…
    <div class="pf-content">
      <div class="screen" data-screen="home">
        <button data-nav="settings">前往設定</button>
        <button data-modal="confirm-sheet">送出</button>
        <button data-toggle="on" aria-pressed="false">通知開關</button>
      </div>
      <div class="screen" data-screen="settings">…</div>
      <div class="modal" data-modal-id="confirm-sheet">…<button data-close>關閉</button></div>
    </div>
  </div>
</div>

<script>
// 事件委派：每台手機一個獨立 scope，互不干擾
document.querySelectorAll('.phone').forEach(phone => {
  const show = id => phone.querySelectorAll('.screen').forEach(s =>
    s.classList.toggle('active', s.dataset.screen === id));
  show(phone.dataset.initial);
  phone.addEventListener('click', e => {
    const t = e.target.closest('[data-nav],[data-modal],[data-toggle],[data-close]');
    if (!t) return;
    if (t.dataset.nav) show(t.dataset.nav);
    if (t.dataset.modal) phone.querySelector(`[data-modal-id="${t.dataset.modal}"]`)?.classList.add('open');
    if (t.hasAttribute('data-close')) t.closest('.modal').classList.remove('open');
    if (t.hasAttribute('data-toggle')) t.setAttribute('aria-pressed', t.getAttribute('aria-pressed') !== 'true');
  });
});
</script>
```

要點：
- 每台的初始畫面**落在自己負責的主畫面**，但畫面間可互相到達（平鋪的每台都能走到別屏）
- 可點元素一律 `cursor:pointer` + hover/active 回饋（顏色加深用既有 token 配 `color-mix()`/`opacity`，不發明新色）
- 交互狀態要「像真的」：toggle 有開關兩態、modal 有進出、tab 有選中態——半殘的交互比沒有更傷說服力，做不完的交互寧可不放那顆按鈕

## 3. 設備框硬綁定：`shared/assets/phone-frame.html`

mobile prototype 的手機外框**必須**複製 `shared/assets/phone-frame.html` 的 `.pf-*` 樣式與骨架（iPhone 15 Pro 精確規格的 vanilla 移植），**禁止自己手寫**以下任何一項：

- Dynamic Island（固定 124×36、top 12 置中——自己估 99% 撞位置 bug）
- status bar（時間/信號/電池，兩側避讓島的空間很窄）
- home indicator、bezel 圓角外框

畫面內容放進 `.pf-content`（54px top 避讓已處理）。平鋪偏大時整台用外層 `transform: scale()` 縮，不改 frame 內部尺寸。desktop 情境（後台/網頁工具)不用手機外框，維持 `pm-prototype` SKILL.md 的 desktop 版型規則。

## 4. 真圖誠實性測試

demo 級允許放真實圖片（wireframe 模式一律灰塊），但**每張圖先過這一題：「去掉這張圖，資訊是否有損？」**

| 情境 | 判斷 | 動作 |
|---|---|---|
| 內容本身就是圖（創作者頭像牆、商品圖、作品縮圖——功能核心繞著圖轉） | 有損 → 內容圖 | 放。優先用 context pack／使用者提供的真素材；沒有就用免版權來源（Wikimedia Commons／Unsplash／Pexels），或有節制的 CSS 佔位圖形＋標注 |
| 列表封面「配個氣氛圖」、設定頁裝飾 banner、stock 模特 | 無損 → 裝飾 | **不放**。裝飾圖 = AI slop，等同紫漸變 |

- 放進檔案的圖一律 **base64 內嵌**——自包含鐵律不放鬆，單檔挪去哪都不裂圖
- 拿不到合適真圖不卡流程：灰塊＋文字標注誠實佔位（html-craft 誠實佔位原則），交付時明講「圖是佔位」
- 企業內部流程型功能（設定、表單、確認類）多半**本來就不需要照片**——別為了「看起來高級」硬塞圖

## 5. 品位錨點（開工前定調，fallback 首選方向）

CI 嚴格模式鎖死顏色與字型來源，但 tokens 之內仍有大量品位空間。動筆前先按 `html-craft.md` 的「品位錨點」節定調：display 層次（大而輕）、底色溫度（用 tokens 淺色系鋪底而非死白）、單 accent 紀律、一處 120% 細節簽名。prototype 的 120% 細節建議選在**demo 的高潮畫面**（完成態、數據亮點、關鍵確認），那是對方記得住的一幕。

資訊密度分型（克制型/高密度型、每屏 ≥3 處差異化資訊）依 `pm-prototype` SKILL.md Step 1 的判斷落實,這裡不重複。

## 6. 交付前：渲染驗證 + 3 項最小點擊測試

靜態截圖只能看 layout，交互 bug 要點過才會發現。在 `verify.py`（截圖＋console error）之外，加跑 **3 項最小點擊測試**——挑這份 prototype 最關鍵的三個交互（例如：進入下一屏／打開 modal／切換 toggle），用 playwright 快照點擊前後狀態：

```python
# 範例：存成臨時 script 跑（路徑與 selector 換成實際值）
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    page = p.chromium.launch().new_page()
    errors = []; page.on("pageerror", lambda e: errors.append(e))
    page.goto("file:///<輸出檔絕對路徑>")
    page.click("[data-nav='settings']")   # 測試 1：navigate
    page.click("[data-modal='confirm-sheet']")  # 測試 2：modal
    page.click("[data-toggle]")           # 測試 3：toggle
    page.screenshot(path="after-clicks.png", full_page=True)
    assert not errors, errors
```

- 點擊後 `pageerror` 必須為 0，截圖用 Read 肉眼確認狀態真的變了（modal 真的開了、toggle 真的切了）
- 無 playwright 環境照 SKILL.md 的降級規則誠實明講，並提醒對方親手點一遍
