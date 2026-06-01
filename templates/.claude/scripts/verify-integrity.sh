#!/usr/bin/env bash
# /verify-integrity — script ejecutable
# Verifica + restaura integridad config Karen

set -uo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

KAREN_DIR="$HOME/.claude/karen"
CLAUDE_DIR="$HOME/.claude"
LEDGER="$KAREN_DIR/integrity/ledger.sha256"
MCP_PINS="$KAREN_DIR/integrity/mcp-pins.txt"
ACTION="${1:-check}"

mkdir -p "$KAREN_DIR/integrity" "$KAREN_DIR/backups"

WATCH=(
  "$CLAUDE_DIR/settings.json"
  "$CLAUDE_DIR/.mcp.json"
  "$CLAUDE_DIR/hooks"
  "$KAREN_DIR/hooks"
  "$CLAUDE_DIR/agents"
  "$KAREN_DIR/firewall"
  "$KAREN_DIR/policy"
  "$CLAUDE_DIR/CLAUDE.md"
)

current_hash() {
  find "${WATCH[@]}" -type f \( -name '*.md' -o -name '*.json' -o -name '*.sh' -o -name '*.txt' -o -name '*.yaml' -o -name '*.py' \) 2>/dev/null | sort | xargs shasum -a 256 2>/dev/null | shasum -a 256 | awk '{print $1}'
}

echo -e "${BOLD}🛡️  KAREN INTEGRITY CHECK${NC}\n"

case "$ACTION" in
  check)
    CUR=$(current_hash)
    if [ ! -f "$LEDGER" ]; then
      echo -e "${YELLOW}No ledger previo. Creando primer snapshot...${NC}"
      echo "$CUR" > "$LEDGER"
      echo -e "${GREEN}✓ Ledger inicializado.${NC} Hash: ${CUR:0:16}..."
      exit 0
    fi
    PREV=$(cat "$LEDGER")
    if [ "$CUR" = "$PREV" ]; then
      echo -e "${GREEN}✓ Integridad verificada.${NC}"
      echo "  Hash actual: ${CUR:0:16}..."
      echo "  Ledger:      ${PREV:0:16}..."
      echo "  Última verificación: $(stat -f '%Sm' "$LEDGER" 2>/dev/null || stat -c '%y' "$LEDGER" 2>/dev/null)"
      exit 0
    fi
    echo -e "${RED}⚠ INTEGRIDAD COMPROMETIDA${NC}"
    echo "  Hash actual: ${CUR:0:16}..."
    echo "  Ledger:      ${PREV:0:16}..."
    echo ""
    echo "  Acciones:"
    echo "    /verify-integrity accept   ← si reconoces los cambios"
    echo "    /verify-integrity restore  ← si NO los reconoces"
    exit 2
    ;;
  accept)
    CUR=$(current_hash)
    cp "$LEDGER" "$KAREN_DIR/backups/ledger-$(date +%s).bak" 2>/dev/null || true
    echo "$CUR" > "$LEDGER"
    echo -e "${GREEN}✓ Cambios aceptados.${NC} Nuevo ledger: ${CUR:0:16}..."
    ;;
  restore)
    BACKUP=$(ls -t "$KAREN_DIR/backups/"*.tar.gz 2>/dev/null | head -1)
    if [ -z "$BACKUP" ]; then
      echo -e "${RED}✗ No hay backup disponible.${NC}"
      exit 1
    fi
    echo -e "${YELLOW}⚠ Restaurar desde $BACKUP? (y/n)${NC}"
    read -r REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      tar -xzf "$BACKUP" -C / 2>/dev/null
      CUR=$(current_hash)
      echo "$CUR" > "$LEDGER"
      echo -e "${GREEN}✓ Restaurado desde $BACKUP${NC}"
    else
      echo "Cancelado."
    fi
    ;;
  mcp)
    echo -e "${BOLD}MCP Server Pins:${NC}"
    if [ -f "$MCP_PINS" ]; then
      cat "$MCP_PINS"
      echo ""
      bash "$KAREN_DIR/hooks/mcp-pin-verify.sh" < /dev/null 2>&1 || true
    else
      echo -e "${YELLOW}No hay pins MCP aún. Ejecuta hook mcp-pin-verify.sh primero.${NC}"
    fi
    ;;
  full)
    "$0" check
    "$0" mcp
    echo -e "\n${BOLD}Hooks executable check:${NC}"
    for f in "$KAREN_DIR/hooks/"*.sh; do
      [ -x "$f" ] && echo -e "  ${GREEN}✓${NC} $(basename $f)" || echo -e "  ${RED}✗${NC} $(basename $f) NOT EXEC"
    done
    ;;
  *)
    echo "Uso: $0 [check|accept|restore|mcp|full]"
    exit 1
    ;;
esac
