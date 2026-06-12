#!/usr/bin/env bash
# ============================================================
# Karen Hook — PostToolUse Task — citation-required.sh
# Anti-alucinación (v1 = WARN only): si un subagente afirma
# hechos sobre el usuario sin "[source:" → warn + log.
# v2 (futuro): exit 2 para forzar corrección.
# NUNCA bloquea en v1 (exit 0 siempre).
# ============================================================

set -uo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"
trap 'echo "$INPUT"' EXIT

command -v jq >/dev/null 2>&1 || { echo "[KAREN-CITATION] WARN: jq no encontrado, check de citas desactivado." >&2; exit 0; }

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
[ "$TOOL" = "Task" ] || exit 0

# tool_response puede ser string u objeto/array de content blocks
OUTPUT=$(echo "$INPUT" | jq -r '.tool_response // empty | if type == "string" then . else tojson end' 2>/dev/null || echo "")
[ -z "$OUTPUT" ] && exit 0

# Afirmaciones factuales sobre el usuario (v1 — ampliar con el uso)
FACT_REGEX='tu broker( es)?|tienes invertido|tu rutina|tu objetivo|tu cartera|tu patrimonio'

echo "$OUTPUT" | grep -Eiq -- "$FACT_REGEX" || exit 0

# Hay afirmación factual — ¿viene con cita verificable?
if ! echo "$OUTPUT" | grep -Fq -- "[source:"; then
  MATCH=$(echo "$OUTPUT" | grep -Eio -- "$FACT_REGEX" | head -1)
  KAREN_CONFIG_DIR="$HOME/.claude/karen"
  LOG="$KAREN_CONFIG_DIR/security-events.jsonl"
  mkdir -p "$KAREN_CONFIG_DIR"
  TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq -nc --arg ts "$TS" --arg tool "$TOOL" --arg match "${MATCH:-unknown}" \
    '{ts: $ts, type: "citation_missing", tool: $tool, match: $match}' >> "$LOG" 2>/dev/null || true

  echo "[KAREN-CITATION] WARN: subagente afirma hechos sobre el usuario (\"${MATCH:-?}\") sin cita [source:...]." >&2
  echo "[KAREN-CITATION] v1 = solo aviso. Verifica contra memoria antes de aceptar. Evento loggeado en $LOG." >&2
fi

exit 0
