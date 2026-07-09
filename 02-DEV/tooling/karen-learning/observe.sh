#!/usr/bin/env bash
# karen-learning/observe.sh
# Observer de sesiones para el sistema de instintos de Karen.
# Captura observaciones y las escribe en el archivo JSONL del proyecto.

set -euo pipefail

INSTINCTS_DIR="$HOME/Desktop/karen asistente/01-MEMORIA/instincts"
GLOBAL_DIR="$INSTINCTS_DIR/global"
PROJECTS_DIR="$INSTINCTS_DIR/projects"

# Detectar proyecto actual por git remote
detect_project_id() {
  local remote
  remote=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ -n "$remote" ]]; then
    echo "$remote" | md5 | cut -c1-12
  else
    local path
    path=$(git rev-parse --show-toplevel 2>/dev/null || echo "global")
    echo "$path" | md5 | cut -c1-12
  fi
}

PROJECT_ID=$(detect_project_id)
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo 'global')")
PROJECT_OBSERVATIONS="$PROJECTS_DIR/$PROJECT_NAME/observations.jsonl"

mkdir -p "$PROJECTS_DIR/$PROJECT_NAME"
mkdir -p "$GLOBAL_DIR/workflow" "$GLOBAL_DIR/visual" "$GLOBAL_DIR/comunicacion" "$GLOBAL_DIR/dev"

# Registrar observación
log_observation() {
  local type="$1"
  local content="$2"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "{\"timestamp\":\"$timestamp\",\"type\":\"$type\",\"content\":\"$content\",\"project_id\":\"$PROJECT_ID\",\"project_name\":\"$PROJECT_NAME\"}" >> "$PROJECT_OBSERVATIONS"
}

# Mostrar estado de instintos
show_status() {
  echo "=== Karen Instinct System Status ==="
  echo "Project: $PROJECT_NAME ($PROJECT_ID)"
  echo ""
  echo "Global instincts:"
  find "$GLOBAL_DIR" -name "*.md" -not -name "README.md" | while read -r f; do
    confidence=$(grep "^confidence:" "$f" | awk '{print $2}')
    trigger=$(grep "^trigger:" "$f" | sed 's/trigger: //' | tr -d '"')
    echo "  [${confidence:-?}] $(basename "$f" .md): $trigger"
  done

  echo ""
  echo "Project instincts ($PROJECT_NAME):"
  if [[ -d "$PROJECTS_DIR/$PROJECT_NAME/instincts" ]]; then
    find "$PROJECTS_DIR/$PROJECT_NAME/instincts" -name "*.md" | while read -r f; do
      confidence=$(grep "^confidence:" "$f" | awk '{print $2}')
      echo "  [${confidence:-?}] $(basename "$f" .md)"
    done
  else
    echo "  (ninguno todavía)"
  fi

  echo ""
  if [[ -f "$PROJECT_OBSERVATIONS" ]]; then
    echo "Observaciones registradas: $(wc -l < "$PROJECT_OBSERVATIONS")"
  else
    echo "Observaciones registradas: 0"
  fi
}

# Promover instinto de proyecto a global
promote_instinct() {
  local instinct_file="$1"
  local domain
  domain=$(grep "^domain:" "$instinct_file" | awk '{print $2}')
  local dest="$GLOBAL_DIR/${domain:-workflow}"
  mkdir -p "$dest"

  # Actualizar scope
  sed -i '' 's/^scope: project/scope: global/' "$instinct_file"
  sed -i '' '/^project_id:/d' "$instinct_file"

  cp "$instinct_file" "$dest/$(basename "$instinct_file")"
  echo "Instinto promovido a global: $dest/$(basename "$instinct_file")"
}

# CLI
case "${1:-status}" in
  status)
    show_status
    ;;
  observe)
    log_observation "${2:-general}" "${3:-observacion manual}"
    echo "Observación registrada."
    ;;
  promote)
    if [[ -z "${2:-}" ]]; then
      echo "Usage: observe.sh promote <instinct-file>"
      exit 1
    fi
    promote_instinct "$2"
    ;;
  *)
    echo "Usage: observe.sh [status|observe <type> <content>|promote <file>]"
    ;;
esac
