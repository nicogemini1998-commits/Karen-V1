#!/usr/bin/env bash
# ============================================================
# Karen Hook — PreToolUse Write/Edit — secrets-guard.sh
# Bloquea escritura de secretos en archivos no .env
# ============================================================

set -uo pipefail

INPUT="$(cat)"
trap 'echo "$INPUT"' EXIT

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
case "$TOOL" in
  Write|Edit|mcp__hex-line__write_file|mcp__hex-line__edit_file) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo "")
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_text // empty' 2>/dev/null || echo "")

# Skip si archivo es .env legítimo
case "$FILE_PATH" in
  *.env|*.env.*|.env)
    exit 0
    ;;
esac

# Patrones secretos comunes
SECRET_PATTERNS=(
  'sk-ant-[a-zA-Z0-9_-]{20,}'                       # Anthropic API key
  'sk-[a-zA-Z0-9]{20,}'                              # OpenAI / generic
  'AIza[a-zA-Z0-9_-]{30,}'                           # Google API key
  'ghp_[a-zA-Z0-9]{30,}'                             # GitHub PAT classic
  'github_pat_[a-zA-Z0-9_]{50,}'                     # GitHub PAT fine-grained
  'xoxb-[a-zA-Z0-9-]+'                               # Slack bot token
  'AKIA[0-9A-Z]{16}'                                 # AWS access key
  '-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----'  # Private keys
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -Eq "$pattern"; then
    echo "SECRETS_GUARD_BLOCK: secret detectado en escritura a '$FILE_PATH'." >&2
    echo "Patrón coincidente (parcial): $(echo "$CONTENT" | grep -Eo "$pattern" | head -1 | head -c 20)..." >&2
    echo "Mueve secret a .env (gitignored) y referencia con \$VAR_NAME." >&2
    exit 2
  fi
done

exit 0
