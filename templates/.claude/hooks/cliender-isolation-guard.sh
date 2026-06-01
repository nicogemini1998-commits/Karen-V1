#!/usr/bin/env bash
# ============================================================
# Karen Hook — UserPromptSubmit — cliender-isolation-guard.sh
# Detecta menciones Cliender en cuenta personal, alerta
# ============================================================

set -uo pipefail

INPUT="$(cat)"
trap 'echo "$INPUT"' EXIT

USER_MSG=$(echo "$INPUT" | jq -r '.prompt // .user_message // empty' 2>/dev/null || echo "")
[ -z "$USER_MSG" ] && exit 0

# Keywords Cliender (case insensitive)
CLIENDER_KEYWORDS='Cliender|cliender|HBD Revolution|hbdrevolution|hbdeuropa|LeadUp|Studio Cliender|RStudio|GHL.*cliente|sala limpia'

if echo "$USER_MSG" | grep -Eqi "$CLIENDER_KEYWORDS"; then
  # Log incidente
  KAREN_DIR="$HOME/.claude/karen"
  TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  mkdir -p "$KAREN_DIR"
  echo "{\"ts\":\"$TS\",\"type\":\"cliender_mention\",\"msg_preview\":$(echo "$USER_MSG" | head -c 200 | jq -Rs .)}" \
    >> "$KAREN_DIR/cliender-mentions.jsonl"

  # Inyectar alerta al context — no bloquea
  WARNING='<karen-alert priority="high">
⚠ CLIENDER DETECTADO en cuenta personal.
Esta cuenta es PERSONAL — Cliender debe operarse desde cuenta empresa (KAREN-Cliender).
Antes de continuar: recuerda a Nico la separación.
Si confirma "sí salto" → procede. Si no → para.
</karen-alert>
'

  # Append warning al prompt vía passthrough
  echo "$INPUT" | jq --arg w "$WARNING" '. + {"_karen_warning": $w}'
  exit 0
fi

exit 0
