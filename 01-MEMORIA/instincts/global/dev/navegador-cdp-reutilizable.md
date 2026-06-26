---
id: navegador-cdp-reutilizable
trigger: "cuando se necesita automatizar browser, scraping, analítica de redes o interacción con web"
confidence: 0.85
domain: dev
scope: global
created: 2026-06-26
---

# Karen controla el navegador vía CDP — usar siempre esto primero

## Acción
Antes de instalar cualquier herramienta de browser automation, verificar que CDP está activo:
```bash
BU_CDP_URL=http://127.0.0.1:9222 browser-harness <<'PY'
print(page_info())
PY
```
Scripts en `02-DEV/tooling/kanzv-browser/`. Reutilizable para cualquier tarea de browser.

## Cuándo usar CDP de Karen
- Analítica de redes sociales (KANZV, Instagram, TikTok)
- Scraping con sesión logueada de Nico
- Benchmarking de competidores
- Automatización de cualquier web app

## Lo que NO hacer
- Instalar Puppeteer/Playwright nuevo cuando CDP ya está activo.
- Abrir nueva sesión de browser sin verificar :9222 primero.

## Evidencia
- CDP activo en :9222 desde jun 2026.
- Scripts KANZV browser en 02-DEV/tooling/kanzv-browser/.
- Registrado en memoria: `capacidad-navegador-cdp.md`.
