#!/usr/bin/env bash
# ============================================================
# Karen Hook — PreToolUse Bash — npm-supply-chain-guard.sh
# Defeats T1.2 (axios Mar 2026 — npm/pnpm supply chain RAT)
# Enforce: lockfile + --ignore-scripts + audit gate
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

INPUT="$(cat 2>/dev/null || echo '{}')"
trap 'echo "$INPUT"' EXIT

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
[ -z "$CMD" ] && exit 0

# Solo aplicar a comandos de install
if ! echo "$CMD" | grep -Eq '\b(npm|pnpm|yarn|bun)[[:space:]]+(install|add|i)([[:space:]]|$)'; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || pwd)
[ -z "$CWD" ] && CWD="$PWD"

# cd fallido NO puede ser bypass del guard (antes: || exit 0 permitía el install)
if ! cd "$CWD" 2>/dev/null; then
  echo "[KAREN-SUPPLY-CHAIN] BLOCKED: cwd inválido ('$CWD') — no se puede verificar lockfile." >&2
  exit 2
fi

# 1. Require lockfile
HAS_LOCK=0
[ -f "package-lock.json" ] && HAS_LOCK=1
[ -f "pnpm-lock.yaml" ] && HAS_LOCK=1
[ -f "yarn.lock" ] && HAS_LOCK=1
[ -f "bun.lockb" ] && HAS_LOCK=1

if [ "$HAS_LOCK" = "0" ]; then
  echo "[KAREN-SUPPLY-CHAIN] BLOCKED: install sin lockfile." >&2
  echo "[KAREN-SUPPLY-CHAIN] Use 'npm ci' / 'pnpm install --frozen-lockfile' con lockfile committed." >&2
  echo "[KAREN-SUPPLY-CHAIN] Razón: lockfile pinea versiones exactas, defeats supply-chain swaps." >&2
  exit 2
fi

# 2. Enforce --ignore-scripts (defeats postinstall RATs como axios)
if ! echo "$CMD" | grep -Eq -- '--ignore-scripts'; then
  echo "[KAREN-SUPPLY-CHAIN] BLOCKED: install debe incluir --ignore-scripts." >&2
  echo "[KAREN-SUPPLY-CHAIN] Razón: incidente axios Mar 2026 — postinstall script desplegaba RAT." >&2
  echo "[KAREN-SUPPLY-CHAIN] Re-ejecuta: $CMD --ignore-scripts" >&2
  exit 2
fi

exit 0
