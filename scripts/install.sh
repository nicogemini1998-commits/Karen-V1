#!/usr/bin/env bash
# ============================================================
# KAREN-V1 install.sh v2.0
# Instalador inteligente — ordenador nuevo a Karen operativa
# ============================================================
# Uso:
#   git clone https://github.com/nicogemini1998-commits/Karen-V1.git ~/karen-personal
#   cd ~/karen-personal
#   bash scripts/install.sh
# ============================================================

set -euo pipefail

# ─── Colores ───────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()    { echo -e "${BLUE}[KAREN]${NC} $1"; }
ok()     { echo -e "${GREEN}[ ✓ ]${NC} $1"; }
warn()   { echo -e "${YELLOW}[ ! ]${NC} $1"; }
err()    { echo -e "${RED}[ ✗ ]${NC} $1"; }
ask()    { echo -e "${CYAN}[ ? ]${NC} $1"; }
phase()  { echo -e "\n${BOLD}${BLUE}━━━ $1 ━━━${NC}\n"; }

# ─── Banner ────────────────────────────────────────────────
cat <<'EOF'

  ╦╔═╔═╗╦═╗╔═╗╔╗╔   ╔═╗ ╦   ╔═╗  ╔═╗
  ╠╩╗╠═╣╠╦╝║╣ ║║║───╠═╣ ║───╠═╝──╠═╣
  ╩ ╩╩ ╩╩╚═╚═╝╝╚╝   ╩ ╩ ╩   ╩    ╩ ╩

  Personal AI Assistant · JARVIS + FRIDAY
  v2.0 — Neural Backbone Installer

EOF

# ─── Detect OS ─────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"
case "$OS" in
  Darwin*) PLATFORM="mac" ;;
  Linux*)  PLATFORM="linux" ;;
  MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
  *) PLATFORM="unknown" ;;
esac
log "Plataforma: $PLATFORM ($ARCH)"

# ─── Variables ─────────────────────────────────────────────
KAREN_ROOT="${KAREN_ROOT:-$HOME/karen-personal}"
CLAUDE_DIR="$HOME/.claude"
KAREN_CONFIG_DIR="$CLAUDE_DIR/karen"

log "Karen root: $KAREN_ROOT"
log "Claude config: $CLAUDE_DIR"

# ─── Verify location ───────────────────────────────────────
if [ ! -d "$KAREN_ROOT" ]; then
  err "Directorio $KAREN_ROOT no existe. Clona repo primero:"
  echo "  git clone https://github.com/nicogemini1998-commits/Karen-V1.git $KAREN_ROOT"
  exit 1
fi

cd "$KAREN_ROOT"

if [ ! -f "CLAUDE.md" ] || [ ! -f "README.md" ]; then
  err "No parece ser repo Karen-V1 (faltan CLAUDE.md/README.md)."
  exit 1
fi

# ────────────────────────────────────────────────────────────
# FASE 1 — Estructura dominios
# ────────────────────────────────────────────────────────────
phase "Fase 1/9: Creando estructura dominios"

DOMAINS=(
  "00-SISTEMA-KAREN/01-RULES"
  "00-SISTEMA-KAREN/02-SKILLS"
  "00-SISTEMA-KAREN/03-HOOKS"
  "01-MEMORIA/dev"
  "01-MEMORIA/finanzas"
  "01-MEMORIA/salud"
  "01-MEMORIA/productividad"
  "01-MEMORIA/aprendizaje"
  "01-MEMORIA/relaciones"
  "01-MEMORIA/hobbies"
  "01-MEMORIA/compras-research"
  "01-MEMORIA/audit"
  "02-DEV/proyectos-activos"
  "02-DEV/snippets"
  "02-DEV/research-tecnica"
  "03-FINANZAS/research-ETFs"
  "03-FINANZAS/fiscalidad-ES"
  "03-FINANZAS/broker-notas"
  "04-SALUD-FITNESS/rutinas"
  "04-SALUD-FITNESS/nutricion"
  "04-SALUD-FITNESS/tracking"
  "05-PRODUCTIVIDAD/notion-sync"
  "05-PRODUCTIVIDAD/calendario-outlook"
  "05-PRODUCTIVIDAD/calendario-gmail"
  "06-APRENDIZAJE/libros"
  "06-APRENDIZAJE/cursos"
  "06-APRENDIZAJE/idiomas"
  "06-APRENDIZAJE/notas-research"
  "07-RELACIONES/drafts"
  "08-HOBBIES"
  "09-COMPRAS-RESEARCH"
  "10-GRAPHIFY/corpus"
  "10-GRAPHIFY/exports"
  "10-GRAPHIFY/neo4j-data"
  "10-GRAPHIFY/mem0-data"
)

for dir in "${DOMAINS[@]}"; do
  mkdir -p "$dir"
  if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
    touch "$dir/.gitkeep"
  fi
done
ok "33 carpetas dominios creadas."

# ────────────────────────────────────────────────────────────
# FASE 2 — MEMORY.md inicial + profile.json
# ────────────────────────────────────────────────────────────
phase "Fase 2/9: Memoria inicial + perfil"

# MEMORY.md índice
if [ ! -f "01-MEMORIA/MEMORY.md" ]; then
  cat > "01-MEMORIA/MEMORY.md" <<'MEMEOF'
# MEMORY.md — Karen AI P.A (Índice)

> Índice memoria por dominio. Solo enlaces, no contenido.

## Perfil base (cross-dominio)
(vacío inicial — `/karen-learn-me` lo llena)

## DEV
(vacío inicial)

## FINANZAS
(vacío inicial — sparring socrático antes de cualquier decisión)

## SALUD
(vacío inicial — disclaimer no-médico siempre)

## PRODUCTIVIDAD
(vacío inicial)

## APRENDIZAJE
(vacío inicial)

## RELACIONES
(vacío inicial — privado)

## HOBBIES
(vacío inicial)

## COMPRAS-RESEARCH
(vacío inicial)
MEMEOF
  ok "01-MEMORIA/MEMORY.md creado."
fi

# Stack personal
if [ ! -f "02-DEV/stack-personal.md" ] && [ -f "templates/karen-personal-root/02-DEV/stack-personal.md" ]; then
  cp "templates/karen-personal-root/02-DEV/stack-personal.md" "02-DEV/stack-personal.md"
  ok "02-DEV/stack-personal.md copiado."
fi

# ────────────────────────────────────────────────────────────
# FASE 3 — Config ~/.claude
# ────────────────────────────────────────────────────────────
phase "Fase 3/9: Configurando ~/.claude/"

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands" \
         "$KAREN_CONFIG_DIR/hooks" "$KAREN_CONFIG_DIR/firewall" \
         "$KAREN_CONFIG_DIR/lib" "$KAREN_CONFIG_DIR/policy" \
         "$KAREN_CONFIG_DIR/integrity" "$KAREN_CONFIG_DIR/backups" \
         "$KAREN_CONFIG_DIR/redteam" "$KAREN_CONFIG_DIR/quarantine"

# Settings.json
if [ -f "templates/.claude/settings.json" ]; then
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    warn "settings.json ya existe. Backup → settings.json.bak-$(date +%s)"
    cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak-$(date +%s)"
  fi
  cp "templates/.claude/settings.json" "$CLAUDE_DIR/settings.json"
  ok "settings.json instalado."
fi

# .mcp.json (substitute <USER>)
if [ -f "templates/.claude/.mcp.json" ]; then
  if [ -f "$CLAUDE_DIR/.mcp.json" ]; then
    warn ".mcp.json existe. Backup → .mcp.json.bak-$(date +%s)"
    cp "$CLAUDE_DIR/.mcp.json" "$CLAUDE_DIR/.mcp.json.bak-$(date +%s)"
  fi
  sed "s|<USER>|$USER|g" "templates/.claude/.mcp.json" > "$CLAUDE_DIR/.mcp.json"
  ok ".mcp.json instalado con tu user ($USER)."
fi

# Agents (subagents Karen)
for f in agents/*.md; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  cp "$f" "$CLAUDE_DIR/agents/$base"
done
ok "Agents copiados a ~/.claude/agents/"

# Subagents settings JSON
if [ -d "templates/.claude/agents-config" ]; then
  cp -r templates/.claude/agents-config/* "$CLAUDE_DIR/agents/" 2>/dev/null || true
  ok "Subagents settings (allowedTools + tier) copiados."
fi

# Commands
for f in commands/*.md; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  cp "$f" "$CLAUDE_DIR/commands/$base"
done
ok "Commands copiados a ~/.claude/commands/"

# Hooks ejecutables
if [ -d "templates/.claude/hooks" ]; then
  cp -r templates/.claude/hooks/* "$KAREN_CONFIG_DIR/hooks/"
  chmod +x "$KAREN_CONFIG_DIR/hooks/"*.sh 2>/dev/null || true
  ok "Hooks ejecutables copiados a ~/.claude/karen/hooks/"
fi

# Firewall rules
if [ -d "templates/.claude/karen/firewall" ]; then
  cp -r templates/.claude/karen/firewall/* "$KAREN_CONFIG_DIR/firewall/"
  ok "Firewall rules copiadas."
fi

# Seed rules
if [ -f "templates/.claude/karen/rules-learned-seed.md" ] && [ ! -f "$KAREN_CONFIG_DIR/rules-learned.md" ]; then
  cp "templates/.claude/karen/rules-learned-seed.md" "$KAREN_CONFIG_DIR/rules-learned.md"
  ok "rules-learned.md seed copiado (15 reglas pre-cargadas)."
fi

# Profile.json
if [ -f "templates/.claude/karen/profile.json" ] && [ ! -f "$KAREN_CONFIG_DIR/profile.json" ]; then
  cp "templates/.claude/karen/profile.json" "$KAREN_CONFIG_DIR/profile.json"
  ok "profile.json template copiado."
fi

# Libraries Python (spotlight, mem_filter, cost_optimizer)
if [ -d "templates/.claude/lib" ]; then
  cp -r templates/.claude/lib/* "$KAREN_CONFIG_DIR/lib/"
  ok "Libraries Python copiadas (spotlight.py, mem_filter.py, cost_optimizer.py)."
fi

# Policy (Rule of Two)
if [ -d "templates/.claude/policy" ]; then
  cp -r templates/.claude/policy/* "$KAREN_CONFIG_DIR/policy/"
  ok "Policy karen-rot.yaml (Rule of Two) copiada."
fi

# Trust log + grants + security events inicial
touch "$KAREN_CONFIG_DIR/trust-log.jsonl"
touch "$KAREN_CONFIG_DIR/grants.jsonl"
touch "$KAREN_CONFIG_DIR/security-events.jsonl"
touch "$KAREN_CONFIG_DIR/audit-log.jsonl"
touch "$KAREN_CONFIG_DIR/cost-log.jsonl"

# ────────────────────────────────────────────────────────────
# FASE 4 — Pre-requisitos
# ────────────────────────────────────────────────────────────
phase "Fase 4/9: Verificando pre-requisitos"

MISSING_DEPS=""

check_cmd() {
  local cmd="$1"
  local install_hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd: $(command -v "$cmd")"
    return 0
  else
    warn "$cmd FALTA. Instala: $install_hint"
    MISSING_DEPS="$MISSING_DEPS $cmd"
    return 1
  fi
}

check_cmd "node"    "https://nodejs.org/ (v20+)" || true
check_cmd "npm"     "viene con node" || true
check_cmd "git"     "https://git-scm.com/" || true
check_cmd "docker"  "https://docker.com/products/docker-desktop/" || true
check_cmd "python3" "https://python.org/" || true
check_cmd "jq"      "brew install jq (mac) / apt install jq (linux)" || true

if [ "$PLATFORM" = "mac" ]; then
  check_cmd "brew" "https://brew.sh/" || true
fi

# ────────────────────────────────────────────────────────────
# FASE 5 — Auto-install opcional deps (mac)
# ────────────────────────────────────────────────────────────
if [ -n "$MISSING_DEPS" ] && [ "$PLATFORM" = "mac" ] && command -v brew >/dev/null 2>&1; then
  phase "Fase 5/9: Auto-instalar deps faltantes (opcional)"
  ask "¿Instalar deps faltantes con brew? (y/n)"
  read -r REPLY || REPLY="n"
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    for cmd in $MISSING_DEPS; do
      case "$cmd" in
        node)    brew install node ;;
        jq)      brew install jq ;;
        python3) brew install python@3.12 ;;
        docker)  brew install --cask docker; warn "Abre Docker Desktop manualmente." ;;
        git)     brew install git ;;
      esac
    done
    ok "Deps instaladas."
  else
    warn "Skip auto-install. Instala manualmente y re-corre script."
  fi
else
  phase "Fase 5/9: Skip auto-install (no brew o sin deps faltantes)"
fi

# ────────────────────────────────────────────────────────────
# FASE 6 — Docker stack (Mem0 + Neo4j)
# ────────────────────────────────────────────────────────────
phase "Fase 6/9: Docker stack memoria (Mem0 + Neo4j)"

if command -v docker >/dev/null 2>&1; then
  if [ -f "templates/docker-compose.memory.yml" ]; then
    cp templates/docker-compose.memory.yml "$KAREN_ROOT/10-GRAPHIFY/docker-compose.yml"
    ok "docker-compose.memory.yml copiado a 10-GRAPHIFY/"

    if [ ! -f "$KAREN_ROOT/.env" ]; then
      if [ -f "templates/.env.example" ]; then
        cp templates/.env.example "$KAREN_ROOT/.env"
        warn "Edita $KAREN_ROOT/.env con tus passwords antes de levantar Docker stack."
      fi
    fi

    ask "¿Levantar Mem0 + Neo4j ahora? (y/n) — necesita Docker running"
    read -r REPLY || REPLY="n"
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      (cd "$KAREN_ROOT/10-GRAPHIFY" && docker compose up -d) && ok "Mem0 (8888) + Neo4j (7474/7687) corriendo." || warn "Docker compose falló. Revisa .env y arranca manual."
    else
      log "Skip levantar Docker. Cuando quieras: cd 10-GRAPHIFY && docker compose up -d"
    fi
  fi
else
  warn "Docker no disponible. Skip stack memoria. Karen usará solo markdown memoria v1."
fi

# ────────────────────────────────────────────────────────────
# FASE 7 — Librerías globales sugeridas
# ────────────────────────────────────────────────────────────
phase "Fase 7/9: Librerías globales sugeridas"

cat <<'NPMGLOBAL'

  Sugiero ejecutar después (opcional, no auto):

    npm install -g typescript pnpm prettier eslint playwright @anthropic-ai/sdk

  Para Python side projects:
    pip3 install --user fastapi uvicorn pydantic sqlmodel httpx pytest

  No las instalo automático para no tocar tu setup sin permiso.

NPMGLOBAL

# ────────────────────────────────────────────────────────────
# FASE 8 — Auto-validación post-install
# ────────────────────────────────────────────────────────────
phase "Fase 8/9: Validación post-instalación"

if [ -f "scripts/verify-install.sh" ]; then
  bash scripts/verify-install.sh || warn "verify-install reportó issues. Revisa output arriba."
else
  warn "verify-install.sh no encontrado, skip validación."
fi

# ────────────────────────────────────────────────────────────
# FASE 9 — Cierre
# ────────────────────────────────────────────────────────────
phase "Fase 9/9: Instalación completa"

cat <<EOF

  ${GREEN}✓ Karen AI P.A instalada base.${NC}

  ${BOLD}Estructura:${NC}    $KAREN_ROOT
  ${BOLD}Config Claude:${NC} $CLAUDE_DIR
  ${BOLD}Karen config:${NC}  $KAREN_CONFIG_DIR

  ${YELLOW}━━━ PRÓXIMOS PASOS ━━━${NC}

  ${BOLD}1.${NC} Abre Claude Code Desktop con login cuenta PERSONAL.

  ${BOLD}2.${NC} Apunta a la carpeta:
       ${CYAN}$KAREN_ROOT${NC}

  ${BOLD}3.${NC} Karen lee ${CYAN}CLAUDE.md + docs/FIRST-RUN.md${NC} automático.
     Ejecuta onboarding turno 1:
       - Saludo Jarvis/Friday.
       - Pide datos faltantes (broker, GitHub token, Notion, etc.).
       - Verifica plugins/MCPs instalados.
       - Configura Graphify namespaces.

  ${BOLD}4.${NC} Instala plugins desde Claude Code:
       ${CYAN}/plugin marketplace${NC}
     habilita mínimo:
       caveman · claude-mem · everything-claude-code
       firecrawl · bigdata-com · brightdata-plugin · circleback

  ${BOLD}5.${NC} Autentica MCPs personales cuando Karen pida:
       Gmail · Google Calendar · GitHub · Notion · Outlook (READ-ONLY)

  ${BOLD}6.${NC} Pide a Karen: ${CYAN}/karen-learn-me${NC}
     → te hace MAX 5 preguntas alta-impacto para terminar onboarding.

  ${BOLD}7.${NC} Empieza a trabajar: ${CYAN}/morning-brief${NC}

  ${BLUE}━━━ LECTURA RECOMENDADA ━━━${NC}
    ${CYAN}docs/FIRST-RUN.md${NC} — guía exacta turno 1 Karen
    ${CYAN}docs/03-arquitectura/NEURAL-ARCHITECTURE.md${NC} — red neuronal Karen
    ${CYAN}docs/02-personalidad-karen/IDENTIDAD.md${NC} — Jarvis + Friday

  ${GREEN}━━━ KAREN ONLINE. BIENVENIDO, NICO. ━━━${NC}

EOF

exit 0
