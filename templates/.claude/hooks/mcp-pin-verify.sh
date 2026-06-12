#!/usr/bin/env bash
# ============================================================
# Karen Hook — SessionStart — mcp-pin-verify.sh
# Verifica MCP servers contra signatures pineadas (defeats T1.3 rug-pull)
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

# Drenar stdin (sin trap EXIT: en SessionStart el stdout se añade al contexto)
INPUT="$(cat 2>/dev/null || echo '{}')"

KAREN_CONFIG_DIR="$HOME/.claude/karen"
PIN_FILE="$KAREN_CONFIG_DIR/integrity/mcp-pins.txt"
MCP_CONFIG="$HOME/.claude/.mcp.json"

mkdir -p "$(dirname "$PIN_FILE")"

[ ! -f "$MCP_CONFIG" ] && exit 0
command -v npm >/dev/null 2>&1 || exit 0

DRIFT=0
ALERT=0
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TEMP_PINS="$(mktemp)"

# Iterar MCP servers
for srv in $(jq -r '.mcpServers | keys[]' "$MCP_CONFIG" 2>/dev/null); do
  # Extraer paquete npm si aplica
  PKG=$(jq -r ".mcpServers[\"$srv\"].args[]?" "$MCP_CONFIG" 2>/dev/null | grep -E '^@?[a-z0-9-]+/[a-z0-9_-]+(@.*)?$' | head -1)

  if [ -z "$PKG" ]; then
    continue  # No es paquete npm (custom command)
  fi

  # Pin previo (se necesita también para preservarlo en paths de skip)
  PINNED=$(grep "^$srv " "$PIN_FILE" 2>/dev/null | awk '{print $2}')

  # Obtener integrity hash actual — capturando stderr de npm view para
  # distinguir network-fail (warn, no block) de package-missing (alerta)
  NPM_ERR="$(mktemp)"
  ACTUAL=$(npm view "$PKG" dist.integrity 2>"$NPM_ERR" || echo "")

  if [ -z "$ACTUAL" ]; then
    if grep -qiE 'E404|404 Not Found' "$NPM_ERR"; then
      # Paquete desaparecido del registry → posible unpublish / rug-pull
      ALERT=1
      echo "[KAREN-MCP-PIN] ALERTA: paquete '$PKG' (server '$srv') NO existe en el registry (E404)." >&2
      echo "  Posible unpublish o rug-pull — verifica antes de seguir usándolo." >&2
      echo "{\"ts\":\"$TS\",\"type\":\"mcp_package_missing\",\"server\":\"$srv\",\"package\":\"$PKG\"}" >> "$KAREN_CONFIG_DIR/security-events.jsonl"
    else
      # Fallo de red (ENOTFOUND/ETIMEDOUT/offline/registry caído) → warn, NO bloquea
      echo "[KAREN-MCP-PIN] WARN: no se pudo consultar '$PKG' ($(head -c 120 "$NPM_ERR" | tr '\n' ' ')) — skip verificación, sin bloqueo." >&2
    fi
    rm -f "$NPM_ERR"
    # Preservar pin existente: TEMP_PINS reemplaza PIN_FILE, no perder estado
    [ -n "$PINNED" ] && echo "$srv $PINNED" >> "$TEMP_PINS"
    continue
  fi
  rm -f "$NPM_ERR"

  if [ -z "$PINNED" ]; then
    # First time — pin (stderr: el stdout de SessionStart va al contexto)
    echo "$srv $ACTUAL" >> "$TEMP_PINS"
    echo "[KAREN-MCP-PIN] First-time pin: $srv = $ACTUAL" >&2
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

if [ "$DRIFT" = "1" ] || [ "$ALERT" = "1" ]; then
  echo "[KAREN-MCP-PIN] Run /verify-integrity mcp to accept new pins or rollback." >&2
  exit 2
fi

exit 0
