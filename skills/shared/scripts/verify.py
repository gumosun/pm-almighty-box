#!/usr/bin/env python3
"""
verify.py — Playwright 封裝，驗證 skill 產出的 HTML（截圖 + 抓 console/page error）

來源：adapted from huashu-design (https://github.com/alchaincyf/huashu-design)
by alchaincyf（花叔），MIT License。搬入 pm-almighty-box 作為產出驗證迴路。

Usage:
    python3 verify.py path/to/output.html                        # 基礎：打開+截圖+抓 console error
    python3 verify.py output.html --viewports 1440x900,375x667   # 多 viewport（prototype 用 375x667）
    python3 verify.py output.html --output ./screenshots/        # 指定輸出目錄
    python3 verify.py output.html --show                         # 非 headless，開真實瀏覽器

依賴：
    pip install playwright
    playwright install chromium
"""

import argparse
import sys
from pathlib import Path


def parse_viewport(s):
    w, h = s.split('x')
    return {'width': int(w), 'height': int(h)}


def verify_html(html_path, viewports=None, slides=0, output_dir=None, show=False, wait=2000):
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("ERROR: playwright 未安裝。")
        print("執行: pip install playwright && playwright install chromium")
        sys.exit(1)

    html_path = Path(html_path).resolve()
    if not html_path.exists():
        print(f"ERROR: 檔案不存在: {html_path}")
        sys.exit(1)

    if output_dir is None:
        output_dir = html_path.parent / 'screenshots'
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    file_url = html_path.as_uri()
    stem = html_path.stem

    if viewports is None:
        viewports = [{'width': 1440, 'height': 900}]

    console_errors = []
    page_errors = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=not show)

        for viewport in viewports:
            context = browser.new_context(viewport=viewport, device_scale_factor=2)
            page = context.new_page()

            page.on("console", lambda msg: console_errors.append(f"[{msg.type}] {msg.text}") if msg.type in ("error", "warning") else None)
            page.on("pageerror", lambda err: page_errors.append(str(err)))

            print(f"\n→ 打開 {file_url} @ {viewport['width']}x{viewport['height']}")
            page.goto(file_url, wait_until='networkidle')
            page.wait_for_timeout(wait)

            if slides > 0:
                for i in range(slides):
                    screenshot_path = output_dir / f"{stem}-slide-{str(i + 1).zfill(2)}.png"
                    page.screenshot(path=str(screenshot_path), full_page=False)
                    print(f"  ✓ slide {i+1} → {screenshot_path.name}")

                    if i < slides - 1:
                        page.keyboard.press('ArrowRight')
                        page.wait_for_timeout(500)
            else:
                suffix = f"-{viewport['width']}x{viewport['height']}" if len(viewports) > 1 else ""
                screenshot_path = output_dir / f"{stem}{suffix}.png"
                page.screenshot(path=str(screenshot_path), full_page=False)
                print(f"  ✓ 截圖 → {screenshot_path.name}")

                full_path = output_dir / f"{stem}{suffix}-full.png"
                page.screenshot(path=str(full_path), full_page=True)
                print(f"  ✓ 完整頁 → {full_path.name}")

            if show:
                print("  (瀏覽器視窗保持開啟，按 Enter 關閉...)")
                input()

            context.close()

        browser.close()

    print("\n" + "=" * 50)
    print("驗證報告")
    print("=" * 50)

    if page_errors:
        print(f"\n❌ Page Errors ({len(page_errors)}):")
        for e in page_errors:
            print(f"  - {e}")
    else:
        print("\n✅ 無 JavaScript 錯誤")

    if console_errors:
        print(f"\n⚠️  Console Errors/Warnings ({len(console_errors)}):")
        for e in console_errors[:20]:
            print(f"  - {e}")
        if len(console_errors) > 20:
            print(f"  ... 還有 {len(console_errors) - 20} 條")
    else:
        print("✅ Console 乾淨")

    print(f"\n📸 截圖保存至: {output_dir}")

    return 0 if not page_errors else 1


def main():
    parser = argparse.ArgumentParser(
        description="Verify HTML outputs with Playwright",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("html_path", help="HTML file path")
    parser.add_argument("--viewports", default="1440x900",
                        help="逗號分隔的 viewport 列表，格式 WxH（預設 1440x900）")
    parser.add_argument("--slides", type=int, default=0,
                        help="幻燈片模式：截前 N 張（需 HTML 支援 ArrowRight 翻頁）")
    parser.add_argument("--output", default=None,
                        help="輸出目錄（預設 HTML 所在目錄的 screenshots/）")
    parser.add_argument("--show", action="store_true",
                        help="非 headless，開真實瀏覽器視窗")
    parser.add_argument("--wait", type=int, default=2000,
                        help="打開頁面後等待的毫秒數（預設 2000）")

    args = parser.parse_args()

    viewports = [parse_viewport(v) for v in args.viewports.split(",")]

    return verify_html(
        html_path=args.html_path,
        viewports=viewports,
        slides=args.slides,
        output_dir=args.output,
        show=args.show,
        wait=args.wait,
    )


if __name__ == "__main__":
    sys.exit(main())
