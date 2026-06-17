// Lee KANZV en vivo conectándose por CDP al Chrome que Nico dejó abierto (puerto 9222).
// Lee la pestaña de Notion ya abierta y logueada (no fuerza URLs que caen en login-wall).
// NO cierra el navegador — solo se asoma.
//
// Uso: node cdp-read.mjs            → lee la pestaña de Notion activa
//      node cdp-read.mjs "<url>"    → navega a esa URL en una pestaña nueva y la lee
import { chromium } from "playwright-core";

const target = process.argv[2];
const browser = await chromium.connectOverCDP("http://localhost:9222");
const ctx = browser.contexts()[0];

let page;
if (target) {
  page = await ctx.newPage();
  await page.goto(target, { waitUntil: "domcontentloaded", timeout: 60000 }).catch(() => {});
  await page.waitForSelector(".notion-page-content", { timeout: 25000 }).catch(() => {});
} else {
  page = ctx.pages().find((p) => /notion/.test(p.url())) ?? ctx.pages()[0];
}
await page.waitForTimeout(1500);

const data = await page.evaluate(() => {
  const el = document.querySelector(".notion-page-content") || document.querySelector("main");
  return { title: document.title, url: location.href, text: (el ? el.innerText : document.body.innerText).trim() };
});

if (/Inicia sesión para ver|log ?in/i.test(data.text.slice(0, 200))) {
  console.log("NO_LOGUEADO — abre/loguéate en la pestaña de Notion KANZV y reintenta.");
} else {
  console.log("TÍTULO:", data.title, "\nURL:", data.url);
  console.log("=== CONTENIDO EN VIVO ===\n" + data.text);
}
if (target) await page.close();
await browser.close(); // con CDP solo DESCONECTA — tu Chrome sigue abierto
