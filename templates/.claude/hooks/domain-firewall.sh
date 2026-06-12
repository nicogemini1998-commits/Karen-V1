#!/usr/bin/env bash
# ============================================================
# Karen Hook — PreToolUse — domain-firewall.sh
# Bloquea acceso cross-dominio según firewall rules
#
# LIMITACIÓN CONOCIDA: el input JSON de los hooks de Claude Code
# NO trae subagent_name/.agent → SUBAGENT siempre resuelve a
# "main" y las reglas por-subagente (firewall/<subagent>.txt) no
# aplican desde el input. Fallback: se intenta la env var
# CLAUDE_AGENT_NAME si existe; con SUBAGENT=main se usa
# firewall/main.txt (si existe) como política base.
#
# Sin trap stdout: los hooks PreToolUse no son filtros stdin/stdout.
# exit 0 = permitir (sin output); exit 2 = bloquear (stderr = motivo).
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

KAREN_DIR="$HOME/.claude/karen"
FIREWALL_DIR="$KAREN_DIR/firewall"

INPUT="$(cat)"

# Extraer subagent + tool + path
# Subagent: el input no lo trae (ver LIMITACIÓN) → env fallback → "main"
SUBAGENT=$(echo "$INPUT" | jq -r '.subagent_name // .agent // empty' 2>/dev/null || echo "")
[ -z "$SUBAGENT" ] && SUBAGENT="${CLAUDE_AGENT_NAME:-main}"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // .tool // empty' 2>/dev/null || echo "")
[ -z "$TOOL" ] && exit 0

# Solo aplicar firewall a herramientas filesystem
case "$TOOL" in
  Read|Edit|Write|Glob|Grep|mcp__hex-line__*) ;;
  *) exit 0 ;;
esac

# Path objetivo
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.pattern // empty' 2>/dev/null || echo "")
[ -z "$FILE_PATH" ] && exit 0

# Reglas firewall por subagent (SUBAGENT=main → firewall/main.txt si existe)
RULES_FILE="$FIREWALL_DIR/${SUBAGENT}.txt"
[ ! -f "$RULES_FILE" ] && exit 0

# Cada línea formato:
#   ALLOW <pattern>
#   DENY  <pattern>
while IFS= read -r line; do
  [ -z "$line" ] && continue
  [[ "$line" =~ ^# ]] && continue

  ACTION=$(echo "$line" | awk '{print $1}')
  PATTERN=$(echo "$line" | awk '{print $2}')

  if [[ "$FILE_PATH" == *"$PATTERN"* ]]; then
    case "$ACTION" in
      DENY)
        echo "DOMAIN_FIREWALL_BLOCK: subagent='$SUBAGENT' tool='$TOOL' path='$FILE_PATH' violates rule '$line'" >&2
        # Log violation
        LOG="$KAREN_DIR/firewall-violations.jsonl"
        TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        echo "{\"ts\":\"$TS\",\"subagent\":\"$SUBAGENT\",\"tool\":\"$TOOL\",\"path\":\"$FILE_PATH\",\"rule\":\"$line\"}" >> "$LOG"
        exit 2
        ;;
      ALLOW)
        exit 0
        ;;
    esac
  fi
done < "$RULES_FILE"

exit 0
