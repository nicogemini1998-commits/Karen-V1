#!/usr/bin/env bash
# ============================================================
# Karen Hook — PreToolUse Write/Edit — raiz-limpia-guard.sh
# Bloquea creación archivos sueltos en raíz proyecto karen-personal
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

INPUT="$(cat)"
trap 'echo "$INPUT"' EXIT

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
[ "$TOOL" != "Write" ] && [ "$TOOL" != "mcp__hex-line__write_file" ] && exit 0

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo "")
[ -z "$FILE_PATH" ] && exit 0

KAREN_ROOT="${KAREN_ROOT:-$HOME/karen-personal}"

# Solo aplicar si path es en karen-personal raíz exacta
case "$FILE_PATH" in
  "$KAREN_ROOT"/*)
    REL="${FILE_PATH#$KAREN_ROOT/}"
    DEPTH=$(echo -n "$REL" | tr -cd '/' | wc -c | tr -d ' ')

    # Si está en raíz (depth=0)
    if [ "$DEPTH" = "0" ]; then
      BASENAME=$(basename "$FILE_PATH")
      # Whitelist raíz (docs base + config estándar de tooling)
      case "$BASENAME" in
        CLAUDE.md|README.md|_ATAJOS.md|CHANGELOG.md|.gitignore|.gitattributes|.env|.env.example|.mcp.json)
          exit 0
          ;;
        package.json|tsconfig.json|.npmrc|Makefile|.eslintrc*|.prettierrc*|docker-compose*.yml)
          exit 0
          ;;
        .*)
          # Dot-files OK
          exit 0
          ;;
        *)
          echo "RAIZ_LIMPIA_BLOCK: archivo '$BASENAME' no permitido en raíz $KAREN_ROOT" >&2
          echo "Mueve a carpeta numerada apropiada (01-MEMORIA/, 02-DEV/, etc.)." >&2
          exit 2
          ;;
      esac
    fi
    ;;
esac

exit 0
