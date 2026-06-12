#!/usr/bin/env bash
# ============================================================
# Karen Hook — UserPromptSubmit — cliender-isolation-guard.sh
# Detecta menciones Cliender en cuenta personal, alerta
# Nota: en UserPromptSubmit el stdout con exit 0 se añade como
# contexto → un ÚNICO output final (JSON hookSpecificOutput).
# Sin trap EXIT: duplicaba/sobrescribía el output y el warning
# se perdía.
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

INPUT="$(cat)"

USER_MSG=$(echo "$INPUT" | jq -r '.prompt // .user_message // empty' 2>/dev/null || echo "")
[ -z "$USER_MSG" ] && exit 0

# Keywords Cliender (case insensitive)
CLIENDER_KEYWORDS='Cliender|cliender|HBD Revolution|hbdrevolution|hbdeuropa|LeadUp|Studio Cliender|RStudio|GHL.*cliente|sala limpia'

if ! echo "$USER_MSG" | grep -Eqi "$CLIENDER_KEYWORDS"; then
  exit 0
fi

# Log incidente
KAREN_DIR="$HOME/.claude/karen"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$KAREN_DIR"
jq -n --arg ts "$TS" --arg preview "$(echo "$USER_MSG" | head -c 200)" \
  '{ts: $ts, type: "cliender_mention", msg_preview: $preview}' \
  >> "$KAREN_DIR/cliender-mentions.jsonl"

# Inyectar alerta al context — no bloquea
WARNING='<karen-alert priority="high">
⚠ CLIENDER DETECTADO en cuenta personal.
Esta cuenta es PERSONAL — Cliender debe operarse desde cuenta empresa (KAREN-Cliender).
Antes de continuar: recuerda a Nico la separación.
Si confirma "sí salto" → procede. Si no → para.
</karen-alert>'

# Único echo final: additionalContext llega al modelo como contexto
jq -n --arg w "$WARNING" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $w}}'

exit 0
