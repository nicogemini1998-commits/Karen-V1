#!/usr/bin/env bash
# ============================================================
# KAREN-V1 install.sh
# Autoinstalación Karen Personal en ordenador nuevo
# ============================================================
# Uso:
#   git clone https://github.com/nicogemini1998-commits/KAREN-V1.git ~/karen-personal
#   cd ~/karen-personal
#   bash scripts/install.sh
# ============================================================

set -e

# ─── Colores ───────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${BLUE}[KAREN]${NC} $1"; }
ok()   { echo -e "${GREEN}[ ✓ ]${NC} $1"; }
warn() { echo -e "${YELLOW}[ ! ]${NC} $1"; }
err()  { echo -e "${RED}[ ✗ ]${NC} $1"; }

# ─── Banner ────────────────────────────────────────────────
cat <<'EOF'

  ╦╔═╔═╗╦═╗╔═╗╔╗╔   ╦  ╦  ╔═╗
  ╠╩╗╠═╣╠╦╝║╣ ║║║───╚╗╔╝──╠═╣
  ╩ ╩╩ ╩╩╚═╚═╝╝╚╝    ╚╝   ╩ ╩

  Personal AI Assistant · JARVIS + FRIDAY
  Initial Setup v1.0

EOF

# ─── Detectar OS ───────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin*) PLATFORM="mac" ;;
  Linux*)  PLATFORM="linux" ;;
  MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
  *) PLATFORM="unknown" ;;
esac
log "Plataforma detectada: $PLATFORM"

# ─── Root path ─────────────────────────────────────────────
KAREN_ROOT="${KAREN_ROOT:-$HOME/karen-personal}"
log "Karen root: $KAREN_ROOT"

if [ ! -d "$KAREN_ROOT" ]; then
  err "Directorio $KAREN_ROOT no existe. Clona el repo primero:"
  echo "  git clone https://github.com/nicogemini1998-commits/KAREN-V1.git $KAREN_ROOT"
  exit 1
fi

cd "$KAREN_ROOT"

# ─── Fase 1: Crear estructura dominios ─────────────────────
log "Fase 1/6: creando estructura de dominios..."

DOMAINS=(
  "00-SISTEMA-KAREN/01-RULES"
  "00-SISTEMA-KAREN/02-SKILLS"
  "01-MEMORIA/dev"
  "01-MEMORIA/finanzas"
  "01-MEMORIA/salud"
  "01-MEMORIA/productividad"
  "01-MEMORIA/aprendizaje"
  "01-MEMORIA/relaciones"
  "01-MEMORIA/hobbies"
  "01-MEMORIA/compras-research"
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
)

for dir in "${DOMAINS[@]}"; do
  mkdir -p "$dir"
  if [ ! -f "$dir/.gitkeep" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
    touch "$dir/.gitkeep"
  fi
done
ok "Estructura dominios creada."

# ─── Fase 2: Copiar plantillas iniciales ──────────────────
log "Fase 2/6: copiando plantillas iniciales..."

if [ -d "templates/karen-personal-root" ]; then
  # Copiar archivos top-level del template root si no existen ya
  for f in templates/karen-personal-root/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ ! -f "$base" ]; then
      cp "$f" "$base"
      ok "Copiado: $base"
    fi
  done
fi

# MEMORY.md inicial
if [ ! -f "01-MEMORIA/MEMORY.md" ]; then
  cat > "01-MEMORIA/MEMORY.md" <<'MEMEOF'
# MEMORY.md — Karen Personal (Índice)

> Índice memoria. Solo enlaces, no contenido.

## Perfil base (cross-dominio)
(vacío inicial — Karen llena en onboarding)

## DEV
(vacío inicial)

## FINANZAS
(vacío inicial)

## SALUD
(vacío inicial)

## PRODUCTIVIDAD
(vacío inicial)

## APRENDIZAJE
(vacío inicial)

## RELACIONES
(vacío inicial)

## HOBBIES
(vacío inicial)

## COMPRAS-RESEARCH
(vacío inicial)
MEMEOF
  ok "01-MEMORIA/MEMORY.md inicial creado."
fi

# Stack personal placeholder
if [ ! -f "02-DEV/stack-personal.md" ]; then
  cp templates/karen-personal-root/02-DEV/stack-personal.md "02-DEV/stack-personal.md" 2>/dev/null || true
fi

# ─── Fase 3: Configurar ~/.claude ──────────────────────────
log "Fase 3/6: configurando ~/.claude/..."

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands"

# Copiar agents si no existen
if [ -d "agents" ]; then
  for f in agents/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ ! -f "$CLAUDE_DIR/agents/$base" ]; then
      cp "$f" "$CLAUDE_DIR/agents/$base"
      ok "Agent: $base"
    else
      warn "Agent ya existe (no sobrescribo): $base"
    fi
  done
fi

# Copiar commands si no existen
if [ -d "commands" ]; then
  for f in commands/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ ! -f "$CLAUDE_DIR/commands/$base" ]; then
      cp "$f" "$CLAUDE_DIR/commands/$base"
      ok "Command: $base"
    else
      warn "Command ya existe (no sobrescribo): $base"
    fi
  done
fi

# settings.json sugerido — copia template solo si no existe
if [ ! -f "$CLAUDE_DIR/settings.json" ] && [ -f "templates/.claude/settings.json" ]; then
  cp "templates/.claude/settings.json" "$CLAUDE_DIR/settings.json"
  ok "settings.json copiado (revisa después)."
else
  warn "settings.json ya existe — NO sobrescribo. Compara con templates/.claude/settings.json"
fi

# .mcp.json sugerido
if [ ! -f "$CLAUDE_DIR/.mcp.json" ] && [ -f "templates/.claude/.mcp.json" ]; then
  # Reemplazar <USER> placeholder por usuario real
  sed "s|<USER>|$USER|g" "templates/.claude/.mcp.json" > "$CLAUDE_DIR/.mcp.json"
  ok ".mcp.json copiado con tu user ($USER)."
else
  warn ".mcp.json ya existe — NO sobrescribo."
fi

# ─── Fase 4: Pre-requisitos ────────────────────────────────
log "Fase 4/6: verificando pre-requisitos..."

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 instalado: $(command -v $1)"
  else
    warn "$1 NO instalado. Instálalo manualmente: $2"
  fi
}

check_cmd "node"   "https://nodejs.org/ (v20+)"
check_cmd "npm"    "viene con node"
check_cmd "git"    "https://git-scm.com/"
check_cmd "docker" "https://www.docker.com/products/docker-desktop/"
check_cmd "python3" "https://www.python.org/"
check_cmd "code"   "VS Code: https://code.visualstudio.com/"

if [ "$PLATFORM" = "mac" ]; then
  check_cmd "brew" "https://brew.sh/"
fi

# ─── Fase 5: Sugerir instalación libs globales ────────────
log "Fase 5/6: librerías globales sugeridas (revisar manualmente)..."

cat <<'NPMGLOBAL'

  Sugiero ejecutar después:

    npm install -g typescript pnpm prettier eslint playwright @anthropic-ai/sdk

  (No lo hago automático para no tocar tu setup sin permiso.)

NPMGLOBAL

# ─── Fase 6: Resumen final ─────────────────────────────────
log "Fase 6/6: resumen final..."

cat <<EOF

  ${GREEN}✓ Karen Personal instalada base.${NC}

  Estructura creada: ${KAREN_ROOT}
  Config Claude: ${CLAUDE_DIR}

  ${YELLOW}PRÓXIMOS PASOS:${NC}

  1. Abre Claude Code Desktop con login cuenta PERSONAL.

  2. Apunta a la carpeta:
       ${KAREN_ROOT}

  3. Claude leerá automáticamente CLAUDE.md y Karen
     ejecutará onboarding (te pedirá broker, GitHub, Notion, etc.).

  4. Instala plugins desde Claude Code:
       /plugin marketplace
     y habilita estos (mínimo):
       - caveman
       - claude-mem
       - everything-claude-code
       - firecrawl
       - bigdata-com
       - brightdata-plugin
       - circleback

  5. Autentica MCPs personales (Gmail, Google Calendar) y
     Outlook empresa READ-ONLY desde Claude Code cuando los pida.

  6. Cuando Karen pregunte, dale:
       - GitHub username/token
       - Broker actual
       - Notion URL (cuando lo tengas)

  ${BLUE}Lectura recomendada antes de empezar:${NC}
    - docs/01-quien-soy/PERFIL_NICO.md
    - docs/02-personalidad-karen/IDENTIDAD.md
    - docs/04-skills-catalogo/SKILLS.md
    - docs/05-workflow/WORKFLOWS.md

  ${GREEN}Karen Personal online. Bienvenido, Nico.${NC}

EOF

exit 0
