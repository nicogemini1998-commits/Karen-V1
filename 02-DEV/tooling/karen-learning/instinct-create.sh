#!/usr/bin/env bash
# instinct-create.sh
# Crear un nuevo instinto desde la línea de comandos.

set -euo pipefail

INSTINCTS_DIR="$HOME/Desktop/karen asistente/01-MEMORIA/instincts"

usage() {
  echo "Usage: instinct-create.sh --id <id> --trigger <trigger> --confidence <0.0-1.0> --domain <workflow|visual|dev|comunicacion|finanzas|salud> --scope <global|project> --action <accion> --evidence <evidencia>"
  exit 1
}

ID=""
TRIGGER=""
CONFIDENCE="0.5"
DOMAIN="workflow"
SCOPE="global"
ACTION=""
EVIDENCE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) ID="$2"; shift 2 ;;
    --trigger) TRIGGER="$2"; shift 2 ;;
    --confidence) CONFIDENCE="$2"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    --scope) SCOPE="$2"; shift 2 ;;
    --action) ACTION="$2"; shift 2 ;;
    --evidence) EVIDENCE="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "$ID" || -z "$TRIGGER" || -z "$ACTION" ]] && usage

DATE=$(date +%Y-%m-%d)

if [[ "$SCOPE" == "global" ]]; then
  DEST="$INSTINCTS_DIR/global/$DOMAIN"
else
  PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo 'unknown')")
  PROJECT_ID=$(git remote get-url origin 2>/dev/null | md5 | cut -c1-12 || echo "local")
  DEST="$INSTINCTS_DIR/projects/$PROJECT_NAME/instincts/$DOMAIN"
fi

mkdir -p "$DEST"
FILE="$DEST/$ID.md"

cat > "$FILE" <<EOF
---
id: $ID
trigger: "$TRIGGER"
confidence: $CONFIDENCE
domain: $DOMAIN
scope: $SCOPE${SCOPE == "project" ? "\nproject_id: $PROJECT_ID\nproject_name: $PROJECT_NAME" : ""}
created: $DATE
---

# $ID

## Acción
$ACTION

## Evidencia
- $EVIDENCE (registrado $DATE)
EOF

echo "Instinto creado: $FILE"
