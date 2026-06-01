#!/usr/bin/env bash
# ============================================================
# Karen Hook — UserPromptSubmit — capture-correction.sh
# Detecta correcciones Nico, extrae regla, append a rules-learned.md
# ============================================================

set -uo pipefail

KAREN_DIR="$HOME/.claude/karen"
RULES_FILE="$KAREN_DIR/rules-learned.md"
CAPTURE_LOG="$KAREN_DIR/captures.jsonl"

# Leer input JSON del hook
INPUT="$(cat)"

# Pass-through al final (hook no bloquea)
trap 'echo "$INPUT"' EXIT

# Extraer mensaje usuario actual
USER_MSG=$(echo "$INPUT" | jq -r '.prompt // .user_message // empty' 2>/dev/null || echo "")
[ -z "$USER_MSG" ] && exit 0

# Patrones de corrección (ES + EN)
CORRECTION_PATTERN='^(no|nope|negativo|ya te dije|cuántas veces|deja de|para de|nunca|jamás|siempre|otra vez|de nuevo|lo hicimos ya|me lo dijiste|stop|wait|hold on|that.s wrong|incorrect)'

if ! echo "$USER_MSG" | grep -iE "$CORRECTION_PATTERN" >/dev/null 2>&1; then
  exit 0
fi

# Es corrección. Log raw para review humana (no llamamos API automático para no consumir).
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

mkdir -p "$KAREN_DIR"

# Append entry pending extraction manual
cat >> "$CAPTURE_LOG" <<EOF
{"timestamp":"$TIMESTAMP","user_message":$(echo "$USER_MSG" | jq -Rs .),"status":"pending_extraction"}
EOF

# Append a rules-learned.md como entrada pendiente
cat >> "$RULES_FILE" <<EOF

## $TIMESTAMP (pending-extraction)
**Corrección detectada:** $(echo "$USER_MSG" | head -c 300)
**Status:** revisar + extraer regla con \`/karen-extract-rule\` o editar manualmente.

EOF

exit 0
