#!/usr/bin/env bash
# ============================================================
# Karen Hook — UserPromptSubmit — capture-correction.sh
# Detecta correcciones Nico, extrae regla via Haiku, append a rules-learned.md
# Si la API falla → encola en corrections-queue.jsonl para retry.
# Rate-limit: skip si el último run fue hace <3s (mtime lockfile).
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

KAREN_DIR="$HOME/.claude/karen"
RULES_FILE="$KAREN_DIR/rules-learned.md"
CAPTURE_LOG="$KAREN_DIR/captures.jsonl"
QUEUE_FILE="$KAREN_DIR/corrections-queue.jsonl"
LOCKFILE="$KAREN_DIR/.capture-correction.lock"
RATE_LIMIT_SECONDS=3
ANTHROPIC_KEY="${ANTHROPIC_API_KEY:-}"

# Sin trap stdout: en UserPromptSubmit el stdout con exit 0 se añade
# como contexto — este hook no debe inyectar nada al modelo.
INPUT="$(cat)"

USER_MSG=$(echo "$INPUT" | jq -r '.prompt // .user_message // empty' 2>/dev/null || echo "")
[ -z "$USER_MSG" ] && exit 0

CORRECTION_PATTERN='^(no[,.]| ?nope|negativo|ya te dije|cuántas veces|deja de|para de|nunca|jamás|otra vez|de nuevo (haciendo|repitiendo)|me lo dijiste|stop[,.]| ?wait|hold on|that.?s wrong|incorrect|mal|fatal|no es eso|no era|equivocada)'

if ! echo "$USER_MSG" | grep -iE "$CORRECTION_PATTERN" >/dev/null 2>&1; then
  exit 0
fi

mkdir -p "$KAREN_DIR"

# Rate-limit simple: skip si el último run fue hace <3s (mtime del lockfile)
NOW=$(date +%s)
if [ -f "$LOCKFILE" ]; then
  LAST=$(stat -f %m "$LOCKFILE" 2>/dev/null || stat -c %Y "$LOCKFILE" 2>/dev/null || echo 0)
  if [ $((NOW - LAST)) -lt "$RATE_LIMIT_SECONDS" ]; then
    exit 0
  fi
fi
touch "$LOCKFILE"

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Get previous assistant message from transcript if available
PREV_ASSISTANT=$(echo "$INPUT" | jq -r '.previous_assistant_message // .last_assistant_response // empty' 2>/dev/null || echo "(no previous context)")

# Log raw capture — jq -n --arg garantiza JSON-escaping correcto (comillas/newlines)
jq -n \
  --arg ts "$TIMESTAMP" \
  --arg msg "$USER_MSG" \
  --arg prev "$(echo "$PREV_ASSISTANT" | head -c 200)" \
  '{ts: $ts, user_message: $msg, prev_assistant_preview: $prev, status: "detected"}' \
  >> "$CAPTURE_LOG"

# Try Haiku extraction if API key available
if [ -n "$ANTHROPIC_KEY" ] && command -v curl >/dev/null 2>&1; then
  EXTRACT_PROMPT="Analiza esta corrección y extrae UNA regla operativa concreta. Output JSON estricto: {\"rule\":\"texto regla en imperativo\",\"domain\":\"<dev|finanzas|salud|productividad|aprendizaje|relaciones|hobbies|compras-research|general>\",\"severity\":\"<low|med|high>\"}.

Corrección del usuario: $USER_MSG

Contexto previo (lo que dijo Karen): $(echo "$PREV_ASSISTANT" | head -c 500)"

  PAYLOAD=$(jq -nc \
    --arg model "claude-haiku-4-5-20251001" \
    --arg prompt "$EXTRACT_PROMPT" \
    '{model: $model, max_tokens: 300, messages: [{role: "user", content: $prompt}]}')

  RESPONSE_FILE="$(mktemp)"
  HTTP_CODE=$(curl -s -m 8 -o "$RESPONSE_FILE" -w '%{http_code}' \
    https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$PAYLOAD" 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" = "200" ]; then
    EXTRACTED=$(jq -r '.content[0].text // empty' "$RESPONSE_FILE" 2>/dev/null | grep -oE '\{[^}]+\}' | head -1)
    rm -f "$RESPONSE_FILE"

    if [ -n "$EXTRACTED" ]; then
      RULE=$(echo "$EXTRACTED" | jq -r '.rule // "extraction_failed"' 2>/dev/null)
      DOMAIN=$(echo "$EXTRACTED" | jq -r '.domain // "general"' 2>/dev/null)
      SEVERITY=$(echo "$EXTRACTED" | jq -r '.severity // "med"' 2>/dev/null)

      cat >> "$RULES_FILE" <<EOF

## $TIMESTAMP
**Contexto Karen anterior:** $(echo "$PREV_ASSISTANT" | head -c 200 | tr '\n' ' ')
**Corrección Nico:** $(echo "$USER_MSG" | tr '\n' ' ')
**Regla extraída:** $RULE
**Dominio:** $DOMAIN
**Severidad:** $SEVERITY
EOF
      exit 0
    fi
  else
    rm -f "$RESPONSE_FILE"
    # API caída / error HTTP → encolar para retry posterior
    jq -n \
      --arg ts "$TIMESTAMP" \
      --arg code "$HTTP_CODE" \
      --arg msg "$USER_MSG" \
      --arg prev "$(echo "$PREV_ASSISTANT" | head -c 500)" \
      '{ts: $ts, http_code: $code, user_message: $msg, prev_assistant: $prev, status: "queued"}' \
      >> "$QUEUE_FILE"
    echo "[KAREN-CAPTURE] WARN: extracción Haiku falló (HTTP $HTTP_CODE) — corrección encolada en $QUEUE_FILE" >&2
  fi
fi

# Fallback: append raw correction for manual review
cat >> "$RULES_FILE" <<EOF

## $TIMESTAMP (pending-extraction)
**Corrección detectada:** $(echo "$USER_MSG" | head -c 300 | tr '\n' ' ')
**Contexto previo:** $(echo "$PREV_ASSISTANT" | head -c 200 | tr '\n' ' ')
**Status:** revisar + extraer regla con \`/karen-extract-rule\` o editar manualmente.
EOF

exit 0
