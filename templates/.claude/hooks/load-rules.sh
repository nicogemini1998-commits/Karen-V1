#!/usr/bin/env bash
# ============================================================
# Karen Hook — SessionStart — load-rules.sh
# Inyecta rules-learned.md + profile.json al inicio de sesión
# ============================================================

set -uo pipefail

KAREN_DIR="$HOME/.claude/karen"
RULES_FILE="$KAREN_DIR/rules-learned.md"
PROFILE_FILE="$KAREN_DIR/profile.json"

OUTPUT=""

# Cargar perfil
if [ -f "$PROFILE_FILE" ]; then
  ALIAS=$(jq -r '.user.alias // "Nico"' "$PROFILE_FILE" 2>/dev/null || echo "Nico")
  LOCATION=$(jq -r '.user.location // "España"' "$PROFILE_FILE" 2>/dev/null || echo "España")
  TONE=$(jq -r '.preferences.tone_default // "friday"' "$PROFILE_FILE" 2>/dev/null || echo "friday")

  OUTPUT+="<karen-profile>
Usuario: $ALIAS · $LOCATION
Tono default: $TONE
Profile completo: $PROFILE_FILE
</karen-profile>

"
fi

# Cargar reglas aprendidas
if [ -f "$RULES_FILE" ]; then
  RULES_COUNT=$(grep -c "^## " "$RULES_FILE" 2>/dev/null || echo "0")

  OUTPUT+="<reglas-aprendidas>
Reglas activas en memoria ($RULES_COUNT entradas). Cúmplelas SIEMPRE.

$(cat "$RULES_FILE")
</reglas-aprendidas>

"
fi

# Output al stdout para inyección al system prompt
if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT"
fi

exit 0
