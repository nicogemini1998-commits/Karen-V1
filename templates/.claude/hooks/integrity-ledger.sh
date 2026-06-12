#!/usr/bin/env bash
# ============================================================
# Karen Hook — SessionStart — integrity-ledger.sh
# SHA256 ledger contra T1.7 (hook rewrite escalation)
# Detecta drift en config crítica Karen
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

# Drenar stdin (sin trap EXIT: en SessionStart el stdout se añade al contexto)
INPUT="$(cat 2>/dev/null || echo '{}')"

KAREN_CONFIG_DIR="$HOME/.claude/karen"
LEDGER="$KAREN_CONFIG_DIR/integrity/ledger.sha256"
mkdir -p "$(dirname "$LEDGER")"

# Archivos críticos a monitorizar
WATCH=(
  "$HOME/.claude/settings.json"
  "$HOME/.claude/.mcp.json"
)

# Añade dirs si existen
[ -d "$HOME/.claude/hooks" ] && WATCH+=("$HOME/.claude/hooks")
[ -d "$HOME/.claude/karen/hooks" ] && WATCH+=("$HOME/.claude/karen/hooks")
[ -d "$HOME/.claude/agents" ] && WATCH+=("$HOME/.claude/agents")
[ -d "$HOME/.claude/karen/firewall" ] && WATCH+=("$HOME/.claude/karen/firewall")
[ -d "$HOME/.claude/karen/policy" ] && WATCH+=("$HOME/.claude/karen/policy")
[ -f "$HOME/.claude/CLAUDE.md" ] && WATCH+=("$HOME/.claude/CLAUDE.md")

# Compute current hash — -print0/-0 soporta paths con espacios;
# sort sobre las líneas de shasum garantiza orden determinista
CUR=$(find "${WATCH[@]}" -type f \( -name '*.md' -o -name '*.json' -o -name '*.sh' -o -name '*.txt' -o -name '*.yaml' -o -name '*.py' \) -print0 2>/dev/null \
      | xargs -0 shasum -a 256 2>/dev/null | sort | shasum -a 256 | awk '{print $1}')

if [ -z "$CUR" ]; then
  exit 0
fi

if [ -f "$LEDGER" ]; then
  PREV=$(cat "$LEDGER")
  if [ "$CUR" != "$PREV" ]; then
    # DRIFT detectado — bloqueante
    TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    cat > "$KAREN_CONFIG_DIR/integrity/drift-$TS.alert" <<EOF
INTEGRITY DRIFT DETECTADO
Timestamp: $TS
Hash anterior: $PREV
Hash actual:   $CUR

Archivos monitoreados:
$(printf '  - %s\n' "${WATCH[@]}")

Acción Nico requerida:
  1. ¿Reconoces cambio reciente? Si SÍ → /verify-integrity accept
  2. Si NO → posible compromise. Revisa diff antes continuar.

NO se procede con tool use hasta verificar.
EOF
    echo "[KAREN-INTEGRITY] CRITICAL: config drift detected. See $KAREN_CONFIG_DIR/integrity/drift-$TS.alert" >&2
    echo "[KAREN-INTEGRITY] Run /verify-integrity to inspect + accept or reject." >&2
    exit 2
  fi
fi

# First run o no drift — actualizar ledger
echo "$CUR" > "$LEDGER"
exit 0
