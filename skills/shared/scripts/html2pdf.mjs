#!/usr/bin/env node
/**
 * html2pdf.mjs — 把單一 HTML（report/BRD/PRD 等可捲動長頁）匯出為向量 PDF
 *
 * 改寫自 huashu-design 的 export_deck_pdf.mjs
 * (https://github.com/alchaincyf/huashu-design, alchaincyf, MIT License)，
 * 從「多檔 deck 逐頁合併」改為「單檔長頁分頁/單長頁」兩種模式。
 *
 * 用法：
 *   node html2pdf.mjs --in <file.html> --out <file.pdf>              # A4 直式分頁（預設，適合傳閱/列印）
 *   node html2pdf.mjs --in <file.html> --out <file.pdf> --single    # 一張與內容等高的長頁（適合螢幕閱讀）
 *   node html2pdf.mjs --in <file.html> --out <file.pdf> --width 1024
 *
 * 特點：
 *   - 文字保留向量（可複製、可搜尋）
 *   - printBackground + emulateMedia('screen')：顏色/背景與瀏覽器所見一致
 *   - 不需要改造 HTML
 *
 * 依賴：playwright（npm install，見同目錄 README.md）
 */

import { chromium } from 'playwright';
import path from 'path';

function parseArgs() {
  const args = { width: 1024, single: false };
  const a = process.argv.slice(2);
  for (let i = 0; i < a.length; i++) {
    const k = a[i].replace(/^--/, '');
    if (k === 'single') { args.single = true; continue; }
    args[k] = a[++i];
  }
  if (!args.in || !args.out) {
    console.error('用法: node html2pdf.mjs --in <file.html> --out <file.pdf> [--single] [--width 1024]');
    process.exit(1);
  }
  args.width = parseInt(args.width);
  return args;
}

async function main() {
  const { in: inFile, out, width, single } = parseArgs();
  const inPath = path.resolve(inFile);
  const outPath = path.resolve(out);

  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width, height: 900 } });
  const page = await ctx.newPage();

  const url = 'file://' + inPath;
  await page.goto(url, { waitUntil: 'networkidle' }).catch(() => page.goto(url));
  await page.waitForTimeout(1200); // 等字型/渲染穩定
  await page.emulateMedia({ media: 'screen' });

  let pdfOptions;
  if (single) {
    // 一張與內容等高的長頁
    const height = await page.evaluate(() => Math.ceil(
      Math.max(document.documentElement.scrollHeight, document.body.scrollHeight)
    ));
    pdfOptions = {
      width: `${width}px`,
      height: `${height}px`,
      printBackground: true,
      margin: { top: 0, right: 0, bottom: 0, left: 0 },
      preferCSSPageSize: false,
    };
  } else {
    // A4 直式分頁，交給瀏覽器斷頁
    pdfOptions = {
      format: 'A4',
      printBackground: true,
      margin: { top: '14mm', right: '12mm', bottom: '14mm', left: '12mm' },
      preferCSSPageSize: false,
    };
  }

  const buf = await page.pdf(pdfOptions);
  const fs = await import('fs/promises');
  await fs.writeFile(outPath, buf);
  await browser.close();

  const kb = (buf.byteLength / 1024).toFixed(0);
  console.log(`✓ Wrote ${outPath}  (${kb} KB, ${single ? 'single long page' : 'A4 paginated'}, vector)`);
}

main().catch(e => { console.error(e); process.exit(1); });
