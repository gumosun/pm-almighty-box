#!/usr/bin/env bash
# pm-almighty-box installer.
#
# 用法：
#   ./install.sh --user                     # 把三個 skill 裝到 ${PMBOX_CLAUDE_DIR:-$HOME/.claude}/skills/
#   ./install.sh --user --force              # 連本地改過的檔也覆蓋
#   ./install.sh --seed-context <path>       # 把 templates/* 鋪進 <path>（已存在不覆蓋）
#
# 升級保護：安裝時把每個檔案的 hash 記進 <claude_dir>/.pmbox-manifest。
# 重跑 --user 時，凡本地被改過的檔案一律跳過並警告，除非加 --force。
set -euo pipefail

BOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE=""
FORCE=0
SEED_TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --user)          MODE="user" ;;
    --force)         FORCE=1 ;;
    --seed-context)
      MODE="seed"
      shift
      SEED_TARGET="${1:-}"
      [ -n "$SEED_TARGET" ] || { echo "--seed-context 需要一個路徑參數"; exit 1; }
      ;;
    -*)              echo "未知選項：$1"; exit 1 ;;
    *)               echo "未知參數：$1"; exit 1 ;;
  esac
  shift
done

if [ -z "$MODE" ]; then
  echo "用法：$0 --user [--force] | --seed-context <path>"
  exit 1
fi

hash_of() { shasum -a 256 "$1" | awk '{print $1}'; }

# 帶升級保護地複製 skills/ 下所有檔案（含 shared/ 工藝守則與 scripts；排除 node_modules）到 <claude_dir>/skills/
copy_skills() {
  local claude_dir="$1"
  local manifest="$claude_dir/.pmbox-manifest"
  local new_manifest
  new_manifest="$(mktemp)"
  mkdir -p "$claude_dir/skills"

  local src rel dst cur recorded skip
  while IFS= read -r src; do
    rel="${src#"$BOX_DIR"/}"
    dst="$claude_dir/$rel"
    mkdir -p "$(dirname "$dst")"
    skip=0
    recorded=""
    if [ -f "$dst" ] && [ "$FORCE" -ne 1 ]; then
      cur="$(hash_of "$dst")"
      if [ -f "$manifest" ]; then
        recorded="$(awk -v f="$rel" '$2==f {print $1}' "$manifest")"
      fi
      if [ -n "$recorded" ]; then
        # 上次是我們裝的：內容變了 = 使用者改過 → 保護
        [ "$cur" != "$recorded" ] && skip=1
      else
        # 沒有安裝記錄的既有檔：與新來源不同就保護
        [ "$cur" != "$(hash_of "$src")" ] && skip=1
      fi
    fi
    if [ "$skip" -eq 1 ]; then
      echo "  ! 跳過 ${rel}（偵測到本地修改；確定要覆蓋請加 --force）"
      # 保留舊記錄，下次仍能辨識這是被改過的檔
      [ -n "$recorded" ] && echo "$recorded $rel" >> "$new_manifest"
    else
      cp "$src" "$dst"
      echo "$(hash_of "$dst") $rel" >> "$new_manifest"
    fi
  done < <(find "$BOX_DIR/skills" -type f ! -path '*/node_modules/*' ! -name 'package-lock.json' ! -name '.DS_Store' | sort)
  mv "$new_manifest" "$manifest"
  echo "  ✓ skills → $claude_dir/skills/（pm-assess / pm-propose / pm-prototype / pm-demo ＋ shared/ 工藝守則與 scripts）"
}

seed_context() {
  local target="$1"
  mkdir -p "$target"
  local src rel dst
  for src in "$BOX_DIR"/templates/*; do
    rel="$(basename "$src")"
    dst="$target/$rel"
    if [ -e "$dst" ]; then
      echo "  ! $dst 已存在 → 跳過"
    else
      cp "$src" "$dst"
      echo "  ✓ $rel"
    fi
  done
}

case "$MODE" in
  user)
    claude_dir="${PMBOX_CLAUDE_DIR:-$HOME/.claude}"
    echo "→ 安裝到 $claude_dir"
    copy_skills "$claude_dir"
    echo ""
    echo "完成。/pm-assess、/pm-propose、/pm-prototype、/pm-demo 現在可用。"
    ;;
  seed)
    echo "→ 鋪脈絡骨架到：$SEED_TARGET"
    seed_context "$SEED_TARGET"
    echo ""
    echo "完成。編輯 $SEED_TARGET 底下的檔案填入你公司的 context。"
    ;;
esac
