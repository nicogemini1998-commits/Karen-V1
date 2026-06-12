#!/usr/bin/env bash
# ============================================================
# Karen Hook — PostToolUse Write/Edit — codegen-scanner.sh
# SAST sobre código generado por Karen
# Detecta: rm -rf, curl|sh, eval $(), hardcoded secrets
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

INPUT="$(cat 2>/dev/null || echo '{}')"
trap 'echo "$INPUT"' EXIT

KAREN_CONFIG_DIR="$HOME/.claude/karen"
LOG="$KAREN_CONFIG_DIR/security-events.jsonl"
mkdir -p "$KAREN_CONFIG_DIR"

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo "")
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

EXT="${FILE##*.}"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Patterns universalmente peligrosos (cualquier lenguaje)
DANGER_PATTERNS=(
  'rm[[:space:]]+-rf[[:space:]]+/($|[^A-Za-z])'                # rm -rf / con boundary
  'rm[[:space:]]+-rf[[:space:]]+\$HOME'                        # rm -rf $HOME
  'rm[[:space:]]+-rf[[:space:]]+~'                             # rm -rf ~
  'curl[^|]*\|[[:space:]]*(sh|bash)'                           # curl | sh
  'wget[^|]*\|[[:space:]]*(sh|bash)'                           # wget | sh
  'eval[[:space:]]*\$\([^)]*curl'                              # eval $(curl ...)
  ':\(\)\{[[:space:]]*:\|:&[[:space:]]*\};:'                   # fork bomb
  'dd[[:space:]]+if=/dev/zero[[:space:]]+of=/dev/[sh]d[a-z]'   # dd overwrite disk
  '/dev/sda'                                                    # raw disk write
  'chmod[[:space:]]+777[[:space:]]+/'                          # chmod 777 /
  'chown[[:space:]]+.*[[:space:]]+/$'                          # chown / recursive
)

FOUND=0
DETAILS=""

for pattern in "${DANGER_PATTERNS[@]}"; do
  MATCHES=$(grep -nE "$pattern" "$FILE" 2>/dev/null | head -3)
  if [ -n "$MATCHES" ]; then
    FOUND=1
    DETAILS+="Pattern: $pattern\n$MATCHES\n\n"
  fi
done

# Specific por lenguaje
case "$EXT" in
  py)
    # Python danger
    PY_DANGER=$(grep -nE '(os\.system|subprocess\.run.*shell=True|pickle\.loads|exec[[:space:]]*\(|eval[[:space:]]*\()' "$FILE" 2>/dev/null | head -5)
    if [ -n "$PY_DANGER" ]; then
      FOUND=1
      DETAILS+="Python danger:\n$PY_DANGER\n\n"
    fi
    ;;
  js|ts|jsx|tsx)
    JS_DANGER=$(grep -nE '(eval[[:space:]]*\(|Function[[:space:]]*\(|child_process\.exec[^F]|dangerouslySetInnerHTML)' "$FILE" 2>/dev/null | head -5)
    if [ -n "$JS_DANGER" ]; then
      FOUND=1
      DETAILS+="JS/TS danger:\n$JS_DANGER\n\n"
    fi
    ;;
  sh|bash)
    # bash specific danger
    BASH_DANGER=$(grep -nE '\$\(.*\$\(.*\)\)|`[^`]*`' "$FILE" 2>/dev/null | head -3)
    if [ -n "$BASH_DANGER" ]; then
      DETAILS+="Bash nested expansion (review):\n$BASH_DANGER\n\n"
    fi
    ;;
esac

if [ "$FOUND" = "1" ]; then
  # Log
  echo "{\"ts\":\"$TS\",\"type\":\"codegen_danger\",\"file\":\"$FILE\",\"details\":$(echo "$DETAILS" | head -c 500 | jq -Rs .)}" >> "$LOG"
  echo "[KAREN-CODEGEN] DANGER detected in $FILE:" >&2
  echo -e "$DETAILS" >&2
  echo "[KAREN-CODEGEN] Si es intencional confirma con Nico. Si no, revisa." >&2
  # Non-blocking warning; bloqueo solo en patrones más críticos
  for p in 'rm[[:space:]]+-rf[[:space:]]+/' ':\(\)\{[[:space:]]*:\|:'; do
    if echo "$DETAILS" | grep -q "$p"; then
      exit 2  # bloqueo destructivos extremos
    fi
  done
fi

# Optional: si semgrep instalado, escan más profundo
if command -v semgrep >/dev/null 2>&1; then
  case "$EXT" in
    py|js|ts|jsx|tsx|go|rb)
      SEMGREP_OUT=$(semgrep --config=auto --quiet --severity=ERROR "$FILE" 2>/dev/null | head -20 || true)
      if [ -n "$SEMGREP_OUT" ]; then
        echo "[KAREN-SEMGREP] Errores en $FILE:" >&2
        echo "$SEMGREP_OUT" >&2
      fi
      ;;
  esac
fi

# Optional: bandit Python
if [ "$EXT" = "py" ] && command -v bandit >/dev/null 2>&1; then
  BANDIT_OUT=$(bandit -q -ll "$FILE" 2>/dev/null | head -20 || true)
  if [ -n "$BANDIT_OUT" ]; then
    echo "[KAREN-BANDIT] Issues HIGH+:" >&2
    echo "$BANDIT_OUT" >&2
  fi
fi

# Optional: shellcheck bash
if [ "$EXT" = "sh" ] && command -v shellcheck >/dev/null 2>&1; then
  SC_OUT=$(shellcheck -S error "$FILE" 2>/dev/null | head -10 || true)
  if [ -n "$SC_OUT" ]; then
    echo "[KAREN-SHELLCHECK] Errores bash:" >&2
    echo "$SC_OUT" >&2
  fi
fi

exit 0
