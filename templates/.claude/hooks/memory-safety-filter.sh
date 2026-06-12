#!/usr/bin/env bash
# ============================================================
# Karen Hook — PostToolUse Write/Edit — memory-safety-filter.sh
# Memory poisoning defense (T1.8 — AgentPoison/EchoLeak):
# toda escritura a 01-MEMORIA/ pasa por lib/mem_filter.py.
# Bloqueado → exit 2 (PostToolUse: Claude ve el error y corrige)
# ============================================================

set -uo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"
trap 'echo "$INPUT"' EXIT

command -v jq >/dev/null 2>&1 || { echo "[KAREN-MEM-FILTER] WARN: jq no encontrado, filtro de memoria desactivado." >&2; exit 0; }

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
case "$TOOL" in
  Write|Edit|mcp__hex-line__write_file|mcp__hex-line__edit_file) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo "")
[ -z "$FILE_PATH" ] && exit 0

# Solo aplica a la memoria Karen
case "$FILE_PATH" in
  *01-MEMORIA/*) ;;
  *) exit 0 ;;
esac

CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // .tool_input.new_text // empty' 2>/dev/null || echo "")
[ -z "$CONTENT" ] && exit 0

# python3 + lib son requisito — si faltan, warn y no bloquea
command -v python3 >/dev/null 2>&1 || { echo "[KAREN-MEM-FILTER] WARN: python3 no encontrado, filtro de memoria desactivado." >&2; exit 0; }

MEM_FILTER="$HOME/.claude/karen/lib/mem_filter.py"
if [ ! -f "$MEM_FILTER" ]; then
  # Fallback repo-local (hooks aún no instalados via install.sh)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
  MEM_FILTER="$SCRIPT_DIR/../lib/mem_filter.py"
fi
[ -f "$MEM_FILTER" ] || { echo "[KAREN-MEM-FILTER] WARN: mem_filter.py no encontrado, filtro de memoria desactivado." >&2; exit 0; }

# Content-only check: IPI signatures, ZWSP smuggling, secretos, oversize
RESULT=$(printf '%s' "$CONTENT" | python3 "$MEM_FILTER" --source "hook:$TOOL" 2>/dev/null)
STATUS=$?

if [ "$STATUS" -eq 2 ]; then
  REASON=$(echo "$RESULT" | jq -r '.reason // "unknown"' 2>/dev/null || echo "unknown")
  KAREN_CONFIG_DIR="$HOME/.claude/karen"
  LOG="$KAREN_CONFIG_DIR/security-events.jsonl"
  mkdir -p "$KAREN_CONFIG_DIR"
  TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq -nc --arg ts "$TS" --arg tool "$TOOL" --arg file "$FILE_PATH" --arg reason "$REASON" \
    '{ts: $ts, type: "memory_safety_block", tool: $tool, file: $file, reason: $reason}' >> "$LOG" 2>/dev/null || true

  echo "[KAREN-MEM-FILTER] BLOCK: contenido peligroso escrito en memoria ($FILE_PATH)." >&2
  echo "[KAREN-MEM-FILTER] Razón: $REASON. Evento loggeado en $LOG." >&2
  echo "[KAREN-MEM-FILTER] El archivo YA se escribió — revierte o limpia esa entrada (sin IPI, sin secretos, sin Unicode invisible, <10k chars)." >&2
  exit 2
elif [ "$STATUS" -ne 0 ]; then
  # Crash del lib ≠ contenido peligroso — warn, no bloquea
  echo "[KAREN-MEM-FILTER] WARN: mem_filter.py falló (exit $STATUS), escritura no validada." >&2
fi

exit 0
