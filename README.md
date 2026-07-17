# pm-almighty-box

**A portable AI arsenal for product managers, built on Claude Code skills.** The engine never changes — you drop in one *context pack* per company, and every output (decision analysis, BRD/PRD, clickable prototype, demo video) speaks that company's strategy, metrics, brand CI, and *your* decision principles.

[繁體中文版 README](README.zh-TW.md)

---

## The six skills

| Pillar | Skill | Eats | Produces |
|---|---|---|---|
| **Decision assessment** | `pm-assess` | A proposal (or competing initiatives) + context pack (strategy / metrics / rubric) | Structured evaluation (impact / cost / strategic fit / risk), priority ranking, technical-option flags, one-line recommendation |
| **Proposal doc suite** | `pm-propose` | A decided initiative + context pack | BRD → PRD in two flavors (human-readable HTML + AI-dev markdown) + a presentable HTML report — all in company CI |
| **Prototype generator** | `pm-prototype` | A feature/flow description + brand tokens | Demo-grade interactive HTML prototype — tiled main screens, every device fully clickable (navigate / modals / toggles), precise phone frame, company CI; plus a quick wireframe mode |
| **Demo video generator** | `pm-demo` | A prototype HTML or screenshots + brand tokens | 30–60s branded MP4 demo animation (optional GIF) — more persuasive than a static prototype |
| **Meeting condenser** | `pm-recap` | A meeting record (transcript or raw notes) + context pack (stakeholders / product / decisions) | Structured recap (decisions / action items / open questions / stakeholder heads-up flags) with per-item confirmed decision write-back to `decisions.md` |
| **Status update generator** | `pm-weekly` | Hand-typed done/doing/blocked bullets + context pack (auto pack-footprint scan) | Audience-tailored, paste-ready status update — plain text by default, with an optional CI-branded HTML version |

The six skills are deliberately **silos**, not a pipeline — a PM's day is ad-hoc tasks on demand, not a fixed assembly line.

## What the output looks like

A `pm-prototype` run against the bundled demo context pack — *"用 pm-prototype 做一個「會員升等進度頁」的可點擊 prototype"* — produces this demo-grade board: 4 tiled main screens (member home → tier progress → benefits comparison → fastest-path recommendation), **every phone independently interactive** (navigate, bottom-sheet modals, toggleable subscription items), every color traceable to `brand-tokens.css`:

![Cartova member-tier prototype, 4 screens](examples/screenshots/prototype-montage.png)

Click through it yourself: [`examples/cartova-member-tier-prototype.html`](examples/cartova-member-tier-prototype.html) (single self-contained file — download and open in any browser).

## Architecture: engine vs. context

```
pm-almighty-box/
├── skills/            ← ENGINE: generic logic, shared across companies
│   ├── pm-assess/  pm-propose/  pm-prototype/  pm-demo/  pm-recap/  pm-weekly/
│   └── shared/        craft rules (HTML + demo-grade prototype), variations &
│                      critique playbooks, phone-frame asset, verify/export toolchain
├── contexts/
│   └── cartova/       ← CONTEXT PACK: one per company (demo pack included)
├── templates/         blank context-pack skeleton (8 files)
└── install.sh         install + hash-manifest upgrade protection
```

The moat lives in the **context pack** — especially `rubric.md`, where you write your own product-judgment principles as quotable criteria. Without it, any AI tool produces generic PM advice; with it, outputs argue from *your* judgment ("retention before acquisition", "no growth metric ships without a counter-metric").

## Demo context pack: Cartova

`contexts/cartova/` is a complete, **fully fictional** demo company — a mid-size curated-lifestyle e-commerce whose strategy centers on CRM and customer lifecycle management (winning the shift from paid acquisition to retention: lifecycle journeys, membership tiers, subscribe & save). All eight files are filled in, so you can clone this repo and exercise every skill immediately. That includes `decisions.md` — a small seeded decision log (membership-tier basis, lifecycle-journey push caps) that `pm-assess` reads and cross-checks, and that `pm-recap` keeps appending to after each meeting (e.g. *"用 pm-recap 整理這份會議紀錄"*).

```
用 pm-assess 評估：會員分級制度 vs 沉睡喚醒旅程，先做哪個？
→ structured assessment citing Cartova's rubric ("time-window priority",
  "counter-metric discipline"), ranked recommendation, flagged stale metrics

用 pm-propose 幫「會員分級制度」寫 BRD 和 PRD
→ BRD keyed to each stakeholder's fears/priorities, dual-format PRD,
  presentation-ready HTML report — all in Cartova teal CI

用 pm-prototype 做一個「會員升等進度頁」的可點擊 prototype
→ single self-contained HTML, 4 tiled iPhone frames, each a mini state
  machine (navigate/modal/toggle), every hex traceable to brand-tokens.css

用 pm-demo 幫「會員升等進度頁」做一支 30 秒 demo 影片
→ 1920×1080 MP4: CI title card → screen-by-screen walkthrough → value close
```

## Output quality gates

HTML outputs pass these gates beyond strict-CI mode:

- **Craft rules** (`skills/shared/html-craft.md`) — type-weight hierarchy, three orders of spatial magnitude, single-accent discipline, an anti-AI-slop blacklist, taste anchors, and a falsifiable four-question craft self-check. Raises the floor from "AI average" to "someone designed this".
- **Demo-grade prototype rules** (`skills/shared/prototype-craft.md`) — tiled main screens where every device is a vanilla mini state machine (no React/CDN, still a single self-contained file), a pixel-accurate vanilla-ported iPhone frame (`assets/phone-frame.html`), an honest-real-image test, and 3 minimal click tests before handoff.
- **Verification loop** (`skills/shared/scripts/verify.py`) — every HTML deliverable is Playwright-rendered, screenshotted, and console-error-checked before handoff; if verification didn't run, the skill says so instead of pretending.
- **Design-direction variations** (`skills/shared/variations.md`) — when direction is ambiguous (or on request): three parallel versions with structurally different skeletons, colors still locked to brand tokens, screenshotted side by side so you choose from real visuals — never from text descriptions. Off by default.
- **5+1-dimension expert critique** (`skills/shared/critique.md`) — concept veto first ("would this still work under another product name? then it's a template"), plus brand consistency / hierarchy / craft / functionality / originality; outputs Keep / Fix (severity-ranked, with concrete numbers) / Quick Wins. Runs on request.
- **Optional exports** — vector PDF (`html2pdf.mjs`) for reports/BRD/PRD; deck→editable PPTX toolchain included.

Craft methodology and toolchain are distilled from [huashu-design](https://github.com/alchaincyf/huashu-design) (alchaincyf, MIT License).

## Install

```bash
# Install skills to ~/.claude/skills/ (hash-manifest protection:
# locally modified files are never overwritten without --force)
./install.sh --user

# Seed a blank context pack for a new company
./install.sh --seed-context contexts/<your-company>
```

## Onboarding a new company

1. `./install.sh --user` — the six skills (+ shared toolchain) land in `~/.claude/skills/`
2. `./install.sh --seed-context contexts/<company>` — lays down the 8-file skeleton (including a blank `decisions.md` — it doesn't need to be pre-filled; `pm-recap` accumulates it as you use it)
3. Fill in strategy / metrics / product / stakeholders / brand CI — and above all **`rubric.md`**, your judgment layer. Use `contexts/cartova/` as the reference for what "filled in well" looks like.

That's the whole point: change companies, keep the arsenal.

## Regression testing

`tests/test-prompts.json` holds behavioral regression prompts — after editing any skill, replay them against the Cartova context and check outputs against the expected mechanisms. `tests/test-install.sh` covers the installer.

## License

[MIT](LICENSE). Vendored/adapted toolchain files from huashu-design retain their MIT attribution — see [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) for the full inventory and original license text.
