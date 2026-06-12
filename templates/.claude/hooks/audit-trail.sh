#!/usr/bin/env bash
# ============================================================
# Karen Hook — PreToolUse * — audit-trail.sh
# Observabilidad: 1 línea JSONL por CADA tool call.
# {ts ISO8601 UTC, tool, args_hash sha256/16, session_id}
# NUNCA bloquea (exit 0 siempre) — es trail, no guard.
# ============================================================

set -uo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"
trap 'echo "$INPUT"' EXIT

# Sin jq no hay parsing — warn una vez y fuera (observabilidad nunca bloquea)
command -v jq >/dev/null 2>&1 || { echo "[KAREN-AUDIT] WARN: jq no encontrado, audit-trail desactivado." >&2; exit 0; }

KAREN_CONFIG_DIR="$HOME/.claude/karen"
LOG="$KAREN_CONFIG_DIR/audit-log.jsonl"
[ -d "$KAREN_CONFIG_DIR" ] || mkdir -p "$KAREN_CONFIG_DIR"

# Hash de los args (sha256, primeros 16 chars) — nunca loggeamos el input en claro
ARGS_HASH=$(printf '%s' "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null | shasum -a 256 2>/dev/null) || ARGS_HASH=""
ARGS_HASH="${ARGS_HASH%% *}"
ARGS_HASH="${ARGS_HASH:0:16}"

# Una sola llamada jq construye la línea completa (ts UTC vía now|todate)
printf '%s' "$INPUT" | jq -c --arg h "${ARGS_HASH:-unknown}" \
  '{ts: (now | todate), tool: (.tool_name // "unknown"), args_hash: $h}
   + (if .session_id then {session_id: .session_id} else {} end)' \
  >> "$LOG" 2>/dev/null || true

exit 0
