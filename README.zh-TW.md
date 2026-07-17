# pm-almighty-box

**可攜的產品主管 AI 軍火庫，建立在 Claude Code skills 上。** 引擎不變——每到一間公司灌一份 *context pack*，所有產出（決策評估、BRD/PRD、可點擊 prototype、demo 影片）就會說那間公司的策略、數據、品牌 CI，以及**你自己的決策準則**。

[English README](README.md)

---

## 四個 skill

| 柱 | Skill | 吃進 | 吐出 |
|---|---|---|---|
| **決策評估** | `pm-assess` | 一個提案（或多個競爭 initiative）＋ context pack（策略／數據／rubric） | 結構化評估（影響／成本／戰略契合／風險）＋排序建議＋技術方案選項標註＋一句話 recommendation |
| **提案文件組** | `pm-propose` | 已決定的 initiative ＋ context pack | BRD→PRD 雙版本（人讀 HTML ＋ AI 開發用 md）＋可簡報的 HTML report——全套公司 CI |
| **Prototype 產生器** | `pm-prototype` | 一個功能／流程描述＋ brand tokens | 可在瀏覽器點擊的 HTML wireframe，mobile frame 為主，套公司 CI |
| **Demo 影片產生器** | `pm-demo` | prototype HTML 或畫面截圖＋ brand tokens | 30–60 秒套 CI 的 MP4 demo 動畫（可選 GIF）——比靜態 prototype 更有說服力 |

四個 skill 刻意做成**獨立 silo**、不串成管線——PM 的日常是隨叫隨用的任務，不是固定產線。

## 架構：引擎與脈絡分離

```
pm-almighty-box/
├── skills/            ← 引擎：通用邏輯，跨公司共用
│   ├── pm-assess/  pm-propose/  pm-prototype/  pm-demo/
│   └── shared/        HTML 工藝守則＋驗證/匯出工具鏈
├── contexts/
│   └── cartova/       ← Context pack：每公司一份（內含示範包）
├── templates/         空白 context pack 骨架（7 份檔案）
└── install.sh         安裝＋ hash-manifest 升級保護
```

護城河在 **context pack**——尤其是 `rubric.md`：把你自己的產品判斷直覺寫成可被引用的判準句。沒有這層，任何 AI 工具產的都是通用 PM 建議；有這層，產出用的是**你的判斷**（「留客先於獲客」「沒有 counter-metric 的成長指標不准立案」）。

## 示範 context pack：Cartova

`contexts/cartova/` 是一間**完全虛構**的示範公司——中型生活選物電商，策略核心是 CRM 與客戶生命週期管理（從買流量轉向留客：生命週期旅程、會員分級、訂閱回購）。七份檔案全數填實，clone 下來立刻可以跑通每個 skill：

```
用 pm-assess 評估：會員分級制度 vs 沉睡喚醒旅程，先做哪個？
→ 引用 Cartova rubric（「時效窗口優先」「counter-metric 紀律」）的結構化評估、
  排序建議、並主動標注過期數據

用 pm-propose 幫「會員分級制度」寫 BRD 和 PRD
→ 逐一對照 stakeholders 在意/怕聽的 BRD、雙格式 PRD、可簡報 HTML report——
  全套 Cartova teal CI

用 pm-prototype 做一個「會員升等進度頁」的可點擊 prototype
→ 單一自包含 HTML、375px mobile frame、可點擊換屏、
  每個 hex 都可追溯回 brand-tokens.css

用 pm-demo 幫「會員升等進度頁」做一支 30 秒 demo 影片
→ 1920×1080 MP4：CI title card → 逐屏 walkthrough → 收尾價值一句話
```

## 產出品質關卡

HTML 產出除了 CI 嚴格模式，另有三道關卡：

- **工藝守則**（`skills/shared/html-craft.md`）：字重層次、空間三數量級、單一 accent 紀律、反 AI slop 黑名單、可證偽的 craft 自檢四題——把版面下限從「AI 平均值」抬到「有人設計過」。
- **驗證迴路**（`skills/shared/scripts/verify.py`）：每份 HTML 交付前 Playwright 渲染＋截圖＋抓 console error；沒驗證就明講，不假裝。
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

1. `./install.sh --user`——四個 skill（＋shared 工具層）進 `~/.claude/skills/`
2. `./install.sh --seed-context contexts/<company>`——鋪出七份骨架檔案
3. 填入該公司的策略／數據／產品／組織／品牌 CI——尤其是 **`rubric.md`**（你的判斷層）。「填得好長什麼樣」參考 `contexts/cartova/`。

這就是整個工具的重點：**換公司，軍火庫帶著走。**

## 迴歸測試

`tests/test-prompts.json` 是行為迴歸測試——改版任何 skill 後，對 Cartova context 重放這些 prompt、對照 expected 驗收機制有沒有退化。`tests/test-install.sh` 覆蓋安裝器。

## License

[MIT](LICENSE)——內含的 huashu-design 工具鏈保留其 MIT attribution。
