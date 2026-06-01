#!/usr/bin/env bash
# ============================================================
# Karen Hook — PostToolUse Bash — post-bash-secret-scan.sh
# Detecta secretos en outputs Bash (no solo writes)
# Defeats T1.1 exfil / OWASP LLM02
# ============================================================

set -uo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"
trap 'echo "$INPUT"' EXIT

KAREN_CONFIG_DIR="$HOME/.claude/karen"
LOG="$KAREN_CONFIG_DIR/security-events.jsonl"
mkdir -p "$KAREN_CONFIG_DIR"

# Extraer output Bash
OUTPUT=$(echo "$INPUT" | jq -r '.tool_response.stdout // .tool_response // empty' 2>/dev/null || echo "")
[ -z "$OUTPUT" ] && exit 0

# Patrones secretos comunes (mismo set que secrets-guard, validar output)
SECRET_PATTERNS=(
  'sk-ant-[a-zA-Z0-9_-]{20,}'                       # Anthropic
  'sk-proj-[a-zA-Z0-9_-]{20,}'                      # OpenAI
  'sk-[a-zA-Z0-9]{30,}'                              # OpenAI / generic
  'AIza[a-zA-Z0-9_-]{30,}'                           # Google API
  'ghp_[a-zA-Z0-9]{30,}'                             # GitHub PAT classic
  'github_pat_[a-zA-Z0-9_]{50,}'                     # GitHub PAT fine-grained
  'xoxb-[a-zA-Z0-9-]+'                               # Slack bot
  'xoxp-[a-zA-Z0-9-]+'                               # Slack user
  'AKIA[0-9A-Z]{16}'                                 # AWS access key
  '[a-zA-Z0-9/+=]{40}'                               # generic base64 40
  '-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----'  # Private keys
  'eyJhbGciOi[A-Za-z0-9+/=]{20,}'                    # JWT pattern
)

DETECTED=0
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if echo "$OUTPUT" | grep -Eq -- "$pattern"; then
    DETECTED=1
    # Log event (sin loggear el secreto real, solo pattern)
    echo "{\"ts\":\"$TS\",\"type\":\"secret_in_bash_output\",\"pattern\":\"$(echo "$pattern" | head -c 30)...\"}" >> "$LOG"
  fi
done

if [ "$DETECTED" = "1" ]; then
  echo "[KAREN-SECRET-SCAN] WARNING: secret pattern in Bash output. Logged at $LOG" >&2
  echo "[KAREN-SECRET-SCAN] Review output before sharing externally." >&2
  # Non-blocking — solo warning, no exit 2 (Bash output puede ser legítimo en algunos casos)
fi

exit 0
