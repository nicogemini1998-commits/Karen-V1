#!/usr/bin/env bash
# ============================================================
# Karen Hook — UserPromptSubmit — capture-correction.sh
# Detecta correcciones Nico, extrae regla via Haiku, append a rules-learned.md
# ============================================================

set -uo pipefail

KAREN_DIR="$HOME/.claude/karen"
RULES_FILE="$KAREN_DIR/rules-learned.md"
CAPTURE_LOG="$KAREN_DIR/captures.jsonl"
ANTHROPIC_KEY="${ANTHROPIC_API_KEY:-}"

INPUT="$(cat)"
trap 'echo "$INPUT"' EXIT

USER_MSG=$(echo "$INPUT" | jq -r '.prompt // .user_message // empty' 2>/dev/null || echo "")
[ -z "$USER_MSG" ] && exit 0

CORRECTION_PATTERN='^(no[,.]| ?nope|negativo|ya te dije|cuántas veces|deja de|para de|nunca|jamás|otra vez|de nuevo (haciendo|repitiendo)|me lo dijiste|stop[,.]| ?wait|hold on|that.?s wrong|incorrect|mal|fatal|no es eso|no era|equivocada)'

if ! echo "$USER_MSG" | grep -iE "$CORRECTION_PATTERN" >/dev/null 2>&1; then
  exit 0
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$KAREN_DIR"

# Get previous assistant message from transcript if available
PREV_ASSISTANT=$(echo "$INPUT" | jq -r '.previous_assistant_message // .last_assistant_response // empty' 2>/dev/null || echo "(no previous context)")

# Log raw capture
USER_MSG_JSON=$(echo "$USER_MSG" | jq -Rs .)
echo "{\"ts\":\"$TIMESTAMP\",\"user_message\":$USER_MSG_JSON,\"prev_assistant_preview\":\"$(echo "$PREV_ASSISTANT" | head -c 200 | tr '\n' ' ' | sed 's/"/\\"/g')\",\"status\":\"detected\"}" >> "$CAPTURE_LOG"

# Try Haiku extraction if API key available
if [ -n "$ANTHROPIC_KEY" ] && command -v curl >/dev/null 2>&1; then
  EXTRACT_PROMPT="Analiza esta corrección y extrae UNA regla operativa concreta. Output JSON estricto: {\"rule\":\"texto regla en imperativo\",\"domain\":\"<dev|finanzas|salud|productividad|aprendizaje|relaciones|hobbies|compras-research|general>\",\"severity\":\"<low|med|high>\"}.

Corrección del usuario: $USER_MSG

Contexto previo (lo que dijo Karen): $(echo "$PREV_ASSISTANT" | head -c 500)"

  PAYLOAD=$(jq -nc \
    --arg model "claude-haiku-4-5-20251001" \
    --arg prompt "$EXTRACT_PROMPT" \
    '{model: $model, max_tokens: 300, messages: [{role: "user", content: $prompt}]}')

  RESPONSE=$(curl -s -m 8 https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$PAYLOAD" 2>/dev/null)

  EXTRACTED=$(echo "$RESPONSE" | jq -r '.content[0].text // empty' 2>/dev/null | grep -oE '\{[^}]+\}' | head -1)

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
fi

# Fallback: append raw correction for manual review
cat >> "$RULES_FILE" <<EOF

## $TIMESTAMP (pending-extraction)
**Corrección detectada:** $(echo "$USER_MSG" | head -c 300 | tr '\n' ' ')
**Contexto previo:** $(echo "$PREV_ASSISTANT" | head -c 200 | tr '\n' ' ')
**Status:** revisar + extraer regla con \`/karen-extract-rule\` o editar manualmente.
EOF

exit 0
