# pm-almighty-box

**可攜的產品主管 AI 軍火庫，建立在 Claude Code skills 上。** 引擎不變——每到一間公司灌一份 *context pack*，所有產出（決策評估、BRD/PRD、可點擊 prototype、demo 影片）就會說那間公司的策略、數據、品牌 CI，以及**你自己的決策準則**。

[English README](README.md)

---

## 六個 skill

| 柱 | Skill | 吃進 | 吐出 |
|---|---|---|---|
| **決策評估** | `pm-assess` | 一個提案（或多個競爭 initiative）＋ context pack（策略／數據／rubric） | 結構化評估（影響／成本／戰略契合／風險）＋排序建議＋技術方案選項標註＋一句話 recommendation |
| **提案文件組** | `pm-propose` | 已決定的 initiative ＋ context pack | BRD→PRD 雙版本（人讀 HTML ＋ AI 開發用 md）＋可簡報的 HTML report——全套公司 CI |
| **Prototype 產生器** | `pm-prototype` | 一個功能／流程描述＋ brand tokens | demo 級可交互 HTML prototype——平鋪主屏、每台可點可切（換頁／modal／開關）、精確手機外框、套公司 CI；另有 wireframe 快速模式 |
| **Demo 影片產生器** | `pm-demo` | prototype HTML 或畫面截圖＋ brand tokens | 30–60 秒套 CI 的 MP4 demo 動畫（可選 GIF）——比靜態 prototype 更有說服力 |
| **會議收斂器** | `pm-recap` | 一份會議紀錄（逐字稿或雜記）＋ context pack（stakeholders／product／decisions） | 結構化 recap（決議／行動項／未決事項／stakeholder 知會提醒），決議經逐筆確認後回寫進 `decisions.md` |
| **週報產生器** | `pm-weekly` | 手打的 done/doing/blocked bullets＋ context pack（自動掃本週足跡補漏） | 對受眾客製、可直接貼訊息的週報——預設純文字，可選套 CI 的 HTML 正式版 |

六個 skill 刻意做成**獨立 silo**、不串成管線——PM 的日常是隨叫隨用的任務，不是固定產線。

## 產出長什麼樣

對內附的示範 context pack 跑一次 `pm-prototype`——「用 pm-prototype 做一個『會員升等進度頁』的可點擊 prototype」——產出這個 demo 級平鋪版：4 個主屏並排（會員中心 → 升等進度 → 權益對照 → 最快路徑推薦），**每一台都可獨立操作**（換頁、bottom-sheet 彈窗、訂閱品項開關），每個顏色都可追溯回 `brand-tokens.css`：

![Cartova 會員升等 prototype，4 屏](examples/screenshots/prototype-montage.png)

自己點一遍：[`examples/cartova-member-tier-prototype.html`](examples/cartova-member-tier-prototype.html)（單一自包含檔案，下載後任何瀏覽器可開）。

## 架構：引擎與脈絡分離

```
pm-almighty-box/
├── skills/            ← 引擎：通用邏輯，跨公司共用
│   ├── pm-assess/  pm-propose/  pm-prototype/  pm-demo/  pm-recap/  pm-weekly/
│   └── shared/        工藝守則（HTML＋demo 級 prototype）、變體/評審機制、
│                      手機外框資產、驗證/匯出工具鏈
├── contexts/
│   └── cartova/       ← Context pack：每公司一份（內含示範包）
├── templates/         空白 context pack 骨架（8 份檔案）
└── install.sh         安裝＋ hash-manifest 升級保護
```

護城河在 **context pack**——尤其是 `rubric.md`：把你自己的產品判斷直覺寫成可被引用的判準句。沒有這層，任何 AI 工具產的都是通用 PM 建議；有這層，產出用的是**你的判斷**（「留客先於獲客」「沒有 counter-metric 的成長指標不准立案」）。

## 示範 context pack：Cartova

`contexts/cartova/` 是一間**完全虛構**的示範公司——中型生活選物電商，策略核心是 CRM 與客戶生命週期管理（從買流量轉向留客：生命週期旅程、會員分級、訂閱回購）。八份檔案全數填實，clone 下來立刻可以跑通每個 skill。其中 `decisions.md` 內建幾筆示範決議（會員分級門檻的計算基礎、生命週期旅程推播頻率上限），`pm-assess` 評估時會讀取對照；`pm-recap` 會在每次會議收斂後繼續往裡面 append（例如「用 pm-recap 整理這份會議紀錄」）。

```
用 pm-assess 評估：會員分級制度 vs 沉睡喚醒旅程，先做哪個？
→ 引用 Cartova rubric（「時效窗口優先」「counter-metric 紀律」）的結構化評估、
  排序建議、並主動標注過期數據

用 pm-propose 幫「會員分級制度」寫 BRD 和 PRD
→ 逐一對照 stakeholders 在意/怕聽的 BRD、雙格式 PRD、可簡報 HTML report——
  全套 Cartova teal CI

用 pm-prototype 做一個「會員升等進度頁」的可點擊 prototype
→ 單一自包含 HTML、4 台 iPhone 外框平鋪、每台是迷你狀態機
  （換頁/modal/開關）、每個 hex 都可追溯回 brand-tokens.css

用 pm-demo 幫「會員升等進度頁」做一支 30 秒 demo 影片
→ 1920×1080 MP4：CI title card → 逐屏 walkthrough → 收尾價值一句話
```

## 產出品質關卡

HTML 產出除了 CI 嚴格模式，另有這些關卡：

- **工藝守則**（`skills/shared/html-craft.md`）：字重層次、空間三數量級、單一 accent 紀律、反 AI slop 黑名單、品位錨點、可證偽的 craft 自檢四題——把版面下限從「AI 平均值」抬到「有人設計過」。
- **Demo 級 prototype 守則**（`skills/shared/prototype-craft.md`）：平鋪主屏＋每台是 vanilla 迷你狀態機（不引 React/CDN，仍是單一自包含檔）、精確手機外框（`assets/phone-frame.html`，vanilla 移植）、真圖誠實性測試、交付前 3 項點擊測試。
- **驗證迴路**（`skills/shared/scripts/verify.py`）：每份 HTML 交付前 Playwright 渲染＋截圖＋抓 console error；沒驗證就明講，不假裝。
- **設計方向顧問／變體**（`skills/shared/variations.md`）：方向模糊或想比較時，三版布局骨架互異的真實視覺並排讓你選——顏色仍鎖 brand tokens，絕不丟文字選擇題。預設不開。
- **5+1 維度專家評審**（`skills/shared/critique.md`）：概念一票否決（「換個產品名還成立＝模板」）＋品牌一致性／視覺層級／細節執行／功能性／創新性，輸出 Keep／Fix（三級嚴重度、含具體數值）／Quick Wins。要求時跑。
- **可選匯出**：report/BRD/PRD 可出向量 PDF（`html2pdf.mjs`）；deck→可編輯 PPTX 工具鏈已備妥。

craft 方法論與工具鏈蒸餾自 [huashu-design](https://github.com/alchaincyf/huashu-design)（alchaincyf，MIT License）。

## 安裝

```bash
# 裝 skills 到 ~/.claude/skills/（hash-manifest 升級保護：
# 本地改過的檔案不加 --force 不會被覆蓋）
./install.sh --user

# 幫新公司鋪一份空白 context pack 骨架
./install.sh --seed-context contexts/<your-company>
```

## 到新公司怎麼用

1. `./install.sh --user`——六個 skill（＋shared 工具層）進 `~/.claude/skills/`
2. `./install.sh --seed-context contexts/<company>`——鋪出八份骨架檔案（含空白 `decisions.md`——不用先填，由 `pm-recap` 隨使用累積）
3. 填入該公司的策略／數據／產品／組織／品牌 CI——尤其是 **`rubric.md`**（你的判斷層）。「填得好長什麼樣」參考 `contexts/cartova/`。

這就是整個工具的重點：**換公司，軍火庫帶著走。**

## 迴歸測試

`tests/test-prompts.json` 是行為迴歸測試——改版任何 skill 後，對 Cartova context 重放這些 prompt、對照 expected 驗收機制有沒有退化。`tests/test-install.sh` 覆蓋安裝器。

## License

[MIT](LICENSE)。搬運/改寫自 huashu-design 的工具鏈檔案保留其 MIT attribution——完整清單與原始授權全文見 [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)。
