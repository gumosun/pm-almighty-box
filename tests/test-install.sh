#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export PMBOX_CLAUDE_DIR="$TMP/claude"

# 測 1：--user 裝入三個 skill ＋ shared 層
bash "$ROOT/install.sh" --user
for s in pm-assess pm-propose pm-prototype pm-demo; do
  test -f "$PMBOX_CLAUDE_DIR/skills/$s/SKILL.md" || { echo "FAIL: $s 未安裝"; exit 1; }
done
test -f "$PMBOX_CLAUDE_DIR/.pmbox-manifest" || { echo "FAIL: 無 manifest"; exit 1; }
for f in shared/html-craft.md shared/scripts/verify.py shared/scripts/html2pdf.mjs shared/scripts/README.md shared/assets/animations.jsx shared/scripts/render-video.js; do
  test -f "$PMBOX_CLAUDE_DIR/skills/$f" || { echo "FAIL: $f 未安裝"; exit 1; }
done
test ! -d "$PMBOX_CLAUDE_DIR/skills/shared/scripts/node_modules" || { echo "FAIL: node_modules 不該被安裝"; exit 1; }

# 測 2：升級保護——改過的檔重跑不被覆蓋
echo "LOCAL EDIT" >> "$PMBOX_CLAUDE_DIR/skills/pm-assess/SKILL.md"
bash "$ROOT/install.sh" --user
grep -q "LOCAL EDIT" "$PMBOX_CLAUDE_DIR/skills/pm-assess/SKILL.md" || { echo "FAIL: 升級保護失效"; exit 1; }

# 測 3：--seed-context 鋪骨架
SEED="$TMP/newco"; mkdir -p "$SEED"
bash "$ROOT/install.sh" --seed-context "$SEED"
test -f "$SEED/rubric.md" && test -f "$SEED/brand-tokens.css" || { echo "FAIL: seed 不全"; exit 1; }

echo "ALL PASS"
