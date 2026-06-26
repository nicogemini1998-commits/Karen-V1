#!/usr/bin/env bash
# Lanza un Chrome dedicado con remote-debugging (puerto 9222) y perfil propio.
# Karen se conecta por CDP sin cerrarlo, así la sesión logueada no se pierde.
# El mismo Chrome sirve para varias pestañas/logins (Notion KANZV, Instagram, TikTok…).
#
# Uso: bash launch-cdp.sh [url-inicial]
#   bash launch-cdp.sh                              → abre notion.so
#   bash launch-cdp.sh "https://www.instagram.com"  → abre Instagram (para /redes-live)
set -e
PROFILE="$HOME/.karen-kanzv-cdp"
URL="${1:-https://www.notion.so}"
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --user-data-dir="$PROFILE" \
  --no-first-run --no-default-browser-check \
  "$URL" >/tmp/karen-chrome.log 2>&1 &
echo "Chrome lanzado (perfil: $PROFILE). Puerto CDP: 9222. URL: $URL"
echo "Loguéate en lo que necesites (Notion / Instagram / TikTok) y deja las pestañas abiertas."
