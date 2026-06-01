#!/usr/bin/env bash
# ============================================================
# Karen-V1 verify-install.sh
# Valida instalación post-install.sh
# ============================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

KAREN_ROOT="${KAREN_ROOT:-$HOME/karen-personal}"
CLAUDE_DIR="$HOME/.claude"
KAREN_CONFIG_DIR="$CLAUDE_DIR/karen"

TOTAL=0
PASS=0
FAIL=0
WARN=0

check() {
  local label="$1"
  local cmd="$2"
  TOTAL=$((TOTAL+1))
  if eval "$cmd" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} $label"
    PASS=$((PASS+1))
  else
    echo -e "  ${RED}✗${NC} $label"
    FAIL=$((FAIL+1))
  fi
}

check_warn() {
  local label="$1"
  local cmd="$2"
  TOTAL=$((TOTAL+1))
  if eval "$cmd" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} $label"
    PASS=$((PASS+1))
  else
    echo -e "  ${YELLOW}!${NC} $label (opcional)"
    WARN=$((WARN+1))
  fi
}

echo -e "${BOLD}━━━ KAREN INSTALL VERIFY ━━━${NC}\n"

echo -e "${BOLD}1. Estructura Karen root${NC}"
check "Karen root existe ($KAREN_ROOT)" "[ -d '$KAREN_ROOT' ]"
check "CLAUDE.md" "[ -f '$KAREN_ROOT/CLAUDE.md' ]"
check "README.md" "[ -f '$KAREN_ROOT/README.md' ]"
check "docs/FIRST-RUN.md" "[ -f '$KAREN_ROOT/docs/FIRST-RUN.md' ]"
check "docs/01-quien-soy/PERFIL_NICO.md" "[ -f '$KAREN_ROOT/docs/01-quien-soy/PERFIL_NICO.md' ]"
check "docs/02-personalidad-karen/IDENTIDAD.md" "[ -f '$KAREN_ROOT/docs/02-personalidad-karen/IDENTIDAD.md' ]"
check "docs/03-arquitectura/NEURAL-ARCHITECTURE.md" "[ -f '$KAREN_ROOT/docs/03-arquitectura/NEURAL-ARCHITECTURE.md' ]"

echo -e "\n${BOLD}2. Dominios${NC}"
for d in 01-MEMORIA 02-DEV 03-FINANZAS 04-SALUD-FITNESS 05-PRODUCTIVIDAD 06-APRENDIZAJE 07-RELACIONES 08-HOBBIES 09-COMPRAS-RESEARCH 10-GRAPHIFY; do
  check "Dominio $d existe" "[ -d '$KAREN_ROOT/$d' ]"
done
check "01-MEMORIA/MEMORY.md inicial" "[ -f '$KAREN_ROOT/01-MEMORIA/MEMORY.md' ]"

echo -e "\n${BOLD}3. ~/.claude config${NC}"
check "settings.json instalado" "[ -f '$CLAUDE_DIR/settings.json' ]"
check ".mcp.json instalado" "[ -f '$CLAUDE_DIR/.mcp.json' ]"
check "agents/ contiene karen agents" "ls $CLAUDE_DIR/agents/karen-*.md 2>/dev/null | grep -q karen"
check "commands/ contiene slash commands" "ls $CLAUDE_DIR/commands/*.md 2>/dev/null | head -1 | grep -q md"

echo -e "\n${BOLD}4. Karen config (~/.claude/karen/)${NC}"
check "profile.json" "[ -f '$KAREN_CONFIG_DIR/profile.json' ]"
check "rules-learned.md (seed)" "[ -f '$KAREN_CONFIG_DIR/rules-learned.md' ]"
check "hooks/ existen" "[ -d '$KAREN_CONFIG_DIR/hooks' ]"
check "hook load-rules.sh ejecutable" "[ -x '$KAREN_CONFIG_DIR/hooks/load-rules.sh' ]"
check "hook capture-correction.sh ejecutable" "[ -x '$KAREN_CONFIG_DIR/hooks/capture-correction.sh' ]"
check "hook domain-firewall.sh ejecutable" "[ -x '$KAREN_CONFIG_DIR/hooks/domain-firewall.sh' ]"
check "hook raiz-limpia-guard.sh ejecutable" "[ -x '$KAREN_CONFIG_DIR/hooks/raiz-limpia-guard.sh' ]"
check "hook secrets-guard.sh ejecutable" "[ -x '$KAREN_CONFIG_DIR/hooks/secrets-guard.sh' ]"
check "hook cliender-isolation-guard.sh ejecutable" "[ -x '$KAREN_CONFIG_DIR/hooks/cliender-isolation-guard.sh' ]"
check "firewall/ existe" "[ -d '$KAREN_CONFIG_DIR/firewall' ]"
check "firewall karen-dev.txt" "[ -f '$KAREN_CONFIG_DIR/firewall/karen-dev.txt' ]"
check "firewall karen-finance.txt" "[ -f '$KAREN_CONFIG_DIR/firewall/karen-finance.txt' ]"
check "firewall karen-health.txt" "[ -f '$KAREN_CONFIG_DIR/firewall/karen-health.txt' ]"

echo -e "\n${BOLD}5. Subagents config${NC}"
for agent in karen-dev karen-finance karen-health karen-research karen-learn karen-orchestrator; do
  check_warn "Subagent $agent config JSON" "[ -f '$CLAUDE_DIR/agents/$agent.json' ]"
done

echo -e "\n${BOLD}6. Pre-requisitos sistema${NC}"
check_warn "node 20+" "node --version | grep -E 'v(2[0-9]|[3-9][0-9])'"
check_warn "npm" "command -v npm"
check_warn "git" "command -v git"
check_warn "docker" "command -v docker"
check_warn "python3" "command -v python3"
check_warn "jq (recomendado hooks)" "command -v jq"

echo -e "\n${BOLD}7. Docker memory stack (opcional)${NC}"
if command -v docker >/dev/null 2>&1; then
  check_warn "karen-neo4j running" "docker ps --format '{{.Names}}' | grep -q karen-neo4j"
  check_warn "karen-mem0 running" "docker ps --format '{{.Names}}' | grep -q karen-mem0"
  check_warn "Neo4j health (localhost:7474)" "curl -sf http://localhost:7474 >/dev/null"
  check_warn "Mem0 health (localhost:8888)" "curl -sf http://localhost:8888/health >/dev/null"
else
  echo -e "  ${YELLOW}!${NC} Docker no disponible — skip stack memoria"
fi

echo -e "\n${BOLD}8. .gitignore privacy${NC}"
check ".gitignore en repo" "[ -f '$KAREN_ROOT/.gitignore' ]"
check ".gitignore protege 01-MEMORIA/" "grep -q '01-MEMORIA/' '$KAREN_ROOT/.gitignore'"
check ".gitignore protege 03-FINANZAS/" "grep -q '03-FINANZAS/' '$KAREN_ROOT/.gitignore'"
check ".gitignore protege 04-SALUD-FITNESS/" "grep -q '04-SALUD-FITNESS/' '$KAREN_ROOT/.gitignore'"
check ".gitignore protege settings.local.json" "grep -q 'settings.local.json' '$KAREN_ROOT/.gitignore'"

echo -e "\n${BOLD}━━━ RESUMEN ━━━${NC}"
echo -e "  Total checks: $TOTAL"
echo -e "  ${GREEN}Pass:${NC}   $PASS"
echo -e "  ${YELLOW}Warn:${NC}   $WARN  (opcional / aún por configurar)"
echo -e "  ${RED}Fail:${NC}   $FAIL"
echo

if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}✓ Instalación válida. Karen lista para arrancar.${NC}\n"
  exit 0
else
  echo -e "${RED}${BOLD}✗ Instalación incompleta. Re-ejecuta scripts/install.sh.${NC}\n"
  exit 1
fi
