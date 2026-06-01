#!/usr/bin/env bash
# ============================================================
# Karen Hook — SessionStart — mcp-pin-verify.sh
# Verifica MCP servers contra signatures pineadas (defeats T1.3 rug-pull)
# ============================================================

set -uo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"
trap 'echo "$INPUT"' EXIT

KAREN_CONFIG_DIR="$HOME/.claude/karen"
PIN_FILE="$KAREN_CONFIG_DIR/integrity/mcp-pins.txt"
MCP_CONFIG="$HOME/.claude/.mcp.json"

mkdir -p "$(dirname "$PIN_FILE")"

[ ! -f "$MCP_CONFIG" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v npm >/dev/null 2>&1 || exit 0

DRIFT=0
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TEMP_PINS="$(mktemp)"

# Iterar MCP servers
for srv in $(jq -r '.mcpServers | keys[]' "$MCP_CONFIG" 2>/dev/null); do
  # Extraer paquete npm si aplica
  PKG=$(jq -r ".mcpServers[\"$srv\"].args[]?" "$MCP_CONFIG" 2>/dev/null | grep -E '^@?[a-z0-9-]+/[a-z0-9_-]+(@.*)?$' | head -1)

  if [ -z "$PKG" ]; then
    continue  # No es paquete npm (custom command)
  fi

  # Obtener integrity hash actual
  ACTUAL=$(npm view "$PKG" dist.integrity 2>/dev/null || echo "")
  [ -z "$ACTUAL" ] && continue

  # Check vs pinned
  PINNED=$(grep "^$srv " "$PIN_FILE" 2>/dev/null | awk '{print $2}')

  if [ -z "$PINNED" ]; then
    # First time — pin
    echo "$srv $ACTUAL" >> "$TEMP_PINS"
    echo "[KAREN-MCP-PIN] First-time pin: $srv = $ACTUAL"
  elif [ "$PINNED" != "$ACTUAL" ]; then
    # DRIFT — alert
    DRIFT=1
    echo "[KAREN-MCP-PIN] CRITICAL: $srv integrity changed!" >&2
    echo "  Pinned: $PINNED" >&2
    echo "  Actual: $ACTUAL" >&2
    echo "  Posible rug-pull o legítimo update — verifica manualmente." >&2

    # Log alert
    cat >> "$KAREN_CONFIG_DIR/security-events.jsonl" <<EOF
{"ts":"$TS","type":"mcp_integrity_drift","server":"$srv","pinned":"$PINNED","actual":"$ACTUAL"}
EOF
    # Mantener pin antiguo en archivo
    echo "$srv $PINNED" >> "$TEMP_PINS"
  else
    # OK, keep pin
    echo "$srv $PINNED" >> "$TEMP_PINS"
  fi
done

mv -f "$TEMP_PINS" "$PIN_FILE"

if [ "$DRIFT" = "1" ]; then
  echo "[KAREN-MCP-PIN] Run /verify-integrity mcp to accept new pins or rollback." >&2
  exit 2
fi

exit 0
