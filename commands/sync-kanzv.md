---
description: Sincroniza el Notion de KANZV COUTURE (marca con Pablo) al vault de Obsidian. Vía export manual (robusto) o MCP si algún día el workspace está conectado.
---

# /sync-kanzv

Vuelca/actualiza el espejo de **KANZV COUTURE** (workspace Notion de Nico + Pablo Peral) en Obsidian: `10-GRAPHIFY/KANZV-COUTURE/`. Índice maestro: [[Marca — KANZV COUTURE (con Pablo)]].

## Por qué export y no MCP
El MCP de Notion de Claude Code es una **integración interna** atada al workspace personal de Nico (id `1f8d872b…`). KANZV es un **workspace separado**; las integraciones internas no cruzan workspaces, así que el fetch da 404. El flujo de export es el fiable.

## Comportamiento (vía export — predeterminado)

1. **Localizar el export.** Busca el zip más reciente de Notion en Descargas:
   `ls -lt ~/Downloads/*ExportBlock*.zip` (o el `.zip` más nuevo). Si no hay, pide a Nico que en Notion → página KANZV → `•••` → **Exportar** → *Markdown & CSV* → incluir subpáginas, y que guarde el zip en Descargas.
2. **Extraer con `ditto`** (NO `unzip` — falla por el em-dash `·`/`—` en los nombres). Hay un zip anidado dentro; extrae ambos niveles a una carpeta temporal en `~/Downloads`.
3. **Volcar al vault.** Copia todo (`.md`, `.pdf`, `.csv`) a `10-GRAPHIFY/KANZV-COUTURE/` preservando la estructura.
4. **Limpiar nombres:** quita el patrón ` <32 hex>` de carpetas y archivos (`find -depth` + `sed -E 's/ [0-9a-f]{32}//g'`), de hojas a raíz.
5. **Reparar enlaces internos:** en los `.md`, `sed -i '' -E 's/%20[0-9a-f]{32}//g; s/ [0-9a-f]{32}//g'`.
6. **Diff:** reporta qué cambió respecto al volcado anterior (archivos nuevos / modificados / eliminados). No toques contenido real (un hash dentro del texto, p. ej. IDs de Skool, es legítimo).
7. **Mantener el MOC** `Marca — KANZV COUTURE (con Pablo).md` y el enlace en `_MAPA-CEREBRO`. Cero neuronas huérfanas.
8. **Limpiar temporales** del export en `~/Downloads`.

## Método CDP — lectura en vivo por el navegador (funciona)
Cuando Nico tiene su Chrome dedicado abierto y logueado en KANZV, Karen lee en vivo sin export ni MCP:
1. **Lanzar Chrome** (si no está): `bash 02-DEV/tooling/kanzv-browser/launch-cdp.sh` → abre Chrome con debugging en `:9222` y perfil `~/.karen-kanzv-cdp`. Nico se loguea en Notion (workspace POOR PEOPLE), abre la página KANZV y la deja abierta.
2. **Verificar canal:** `curl -s http://localhost:9222/json/version` debe responder.
3. **Leer:** `node 02-DEV/tooling/kanzv-browser/cdp-read.mjs` lee la pestaña de Notion abierta. Con argumento `node cdp-read.mjs "<url notion>"` navega a otra página y la lee.
4. ⚠️ Notion da login-wall en `app.notion.com/p/<id>` y al forzar el ID directo. El truco: leer la **pestaña ya abierta y logueada** (lo que hace cdp-read sin argumentos), no forzar la URL.
5. `connectOverCDP` solo se asoma: **nunca cierra el Chrome de Nico**, así la sesión persiste entre lecturas.

Sirve para consultas puntuales en vivo ("¿qué dice ahora la página X de KANZV?"). Para un re-volcado masivo de las ~179 páginas, el **export** sigue siendo lo más fiable.

## Si algún día el workspace KANZV está en el MCP
Si `mcp__notion__notion-fetch` con id `37eb88fc7fad80498b1ae1fac4961831` devuelve contenido (no 404): lee el árbol de páginas vía MCP y actualiza el vault directamente, sin export ni navegador. Verifícalo primero con un fetch de ese id.

## Conexiones
- [[Marca — KANZV COUTURE (con Pablo)]]
- [[Herramienta — Notion (hub)]]
- [[Herramienta — Obsidian (este cerebro)]]
- [[verify-creds]]
- [[_MAPA-CEREBRO]]
