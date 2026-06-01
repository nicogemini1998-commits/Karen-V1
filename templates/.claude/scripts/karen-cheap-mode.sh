#!/usr/bin/env bash
# /karen-cheap-mode — activa/desactiva modo eficiencia coste

set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

KAREN_DIR="$HOME/.claude/karen"
STATE_FILE="$KAREN_DIR/cheap-mode.json"
COST_LOG="$KAREN_DIR/cost-log.jsonl"

mkdir -p "$KAREN_DIR"

ACTION="${1:-status}"
BUDGET="${2:-5.00}"

set_state() {
  local enabled="$1"
  local budget="$2"
  cat > "$STATE_FILE" <<EOF
{
  "enabled": $enabled,
  "budget_usd": $budget,
  "since": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "strategies": {
    "haiku_routing": true,
    "prompt_caching": true,
    "md_convert": true,
    "memory_first": true,
    "context_isolation": true,
    "budget_hard_cap": true
  }
}
EOF
}

case "$ACTION" in
  on)
    set_state "true" "$BUDGET"
    echo -e "${GREEN}💰 CHEAP MODE: ON${NC}"
    echo ""
    echo "  Routing:    Default → haiku-4-5; Opus solo whitelist"
    echo "  Caching:    Auto-cache blocks >1024 tokens"
    echo "  Docs:       PDF/docx/xlsx → markitdown antes leer"
    echo "  Memory:     Mem0 + profile.json consultados antes fetch fresh"
    echo "  Budget:     \$$BUDGET USD hard cap"
    echo ""
    echo "  Configura con: /karen-cheap-mode budget <USD>"
    ;;
  off)
    set_state "false" "0"
    echo -e "${YELLOW}💰 CHEAP MODE: OFF${NC}"
    echo "  Routing normal por criticidad (Opus disponible)."
    ;;
  status)
    if [ ! -f "$STATE_FILE" ]; then
      echo -e "${YELLOW}💰 CHEAP MODE: never activated${NC}"
      exit 0
    fi
    ENABLED=$(jq -r '.enabled' "$STATE_FILE" 2>/dev/null || echo "false")
    BUDGET_SET=$(jq -r '.budget_usd' "$STATE_FILE" 2>/dev/null || echo "0")
    SINCE=$(jq -r '.since' "$STATE_FILE" 2>/dev/null || echo "unknown")

    if [ "$ENABLED" = "true" ]; then
      echo -e "${GREEN}💰 CHEAP MODE: ON${NC} (desde $SINCE)"
    else
      echo -e "${YELLOW}💰 CHEAP MODE: OFF${NC}"
    fi
    echo "  Budget: \$$BUDGET_SET"

    # Calc spent from cost-log
    if [ -f "$COST_LOG" ]; then
      TODAY=$(date +%Y-%m-%d)
      SPENT=$(grep "$TODAY" "$COST_LOG" 2>/dev/null | jq -s '[.[].cost_usd] | add // 0' 2>/dev/null || echo "0")
      CALLS=$(grep "$TODAY" "$COST_LOG" 2>/dev/null | wc -l | tr -d ' ')
      echo "  Spent hoy: \$$SPENT (en $CALLS calls)"
      REMAIN=$(python3 -c "print(round(max(0, $BUDGET_SET - $SPENT), 4))" 2>/dev/null || echo "?")
      echo "  Remaining: \$$REMAIN"
    fi
    ;;
  budget)
    if [ -f "$STATE_FILE" ]; then
      ENABLED=$(jq -r '.enabled' "$STATE_FILE" 2>/dev/null)
      set_state "$ENABLED" "$BUDGET"
      echo -e "${GREEN}✓ Budget actualizado a \$$BUDGET${NC}"
    else
      set_state "true" "$BUDGET"
      echo -e "${GREEN}✓ Cheap mode ON con budget \$$BUDGET${NC}"
    fi
    ;;
  reset)
    rm -f "$STATE_FILE"
    echo -e "${YELLOW}✓ State reseteada.${NC}"
    ;;
  *)
    echo "Uso: $0 [on|off|status|budget <USD>|reset]"
    ;;
esac
