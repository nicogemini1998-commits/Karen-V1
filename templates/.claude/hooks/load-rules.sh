#!/usr/bin/env bash
# ============================================================
# Karen Hook — SessionStart — load-rules.sh
# Inyecta rules-learned.md + profile.json al inicio de sesión
# Auto-repara: crea stubs si faltan archivos (nunca no-op
# silencioso), valida profile.json antes de usarlo y mantiene
# backup rotativo de rules-learned.md (últimas 10 copias).
# ============================================================

set -uo pipefail

command -v jq >/dev/null 2>&1 || { echo "[KAREN] CRITICAL: jq no encontrado — hook inoperante" >&2; exit 0; }

KAREN_DIR="$HOME/.claude/karen"
RULES_FILE="$KAREN_DIR/rules-learned.md"
PROFILE_FILE="$KAREN_DIR/profile.json"
BACKUP_DIR="$KAREN_DIR/backups"
MAX_BACKUPS=10

mkdir -p "$KAREN_DIR" "$BACKUP_DIR"

# Stub mínimo si falta rules-learned.md (nunca no-op silencioso)
if [ ! -f "$RULES_FILE" ]; then
  cat > "$RULES_FILE" <<'EOF'
# Reglas aprendidas — KAREN

> Stub creado automáticamente por load-rules.sh.
> Las correcciones de Nico se acumulan aquí (capture-correction.sh).
EOF
  echo "[KAREN-RULES] rules-learned.md no existía — stub creado en $RULES_FILE" >&2
fi

# Stub mínimo válido si falta profile.json
if [ ! -f "$PROFILE_FILE" ]; then
  jq -n '{user: {alias: "Nico", location: "España"}, preferences: {tone_default: "friday"}}' > "$PROFILE_FILE"
  echo "[KAREN-RULES] profile.json no existía — stub creado en $PROFILE_FILE" >&2
fi

# Backup rotativo de rules-learned.md — solo si cambió respecto al último
# backup (evita 10 copias idénticas); se conservan las últimas $MAX_BACKUPS
BACKUP_TS=$(date +%Y%m%d-%H%M%S)
LAST_BACKUP=$(ls -1t "$BACKUP_DIR"/rules-learned.*.md 2>/dev/null | head -1)
if [ -z "$LAST_BACKUP" ] || ! cmp -s "$RULES_FILE" "$LAST_BACKUP"; then
  cp "$RULES_FILE" "$BACKUP_DIR/rules-learned.$BACKUP_TS.md" 2>/dev/null || true
fi
ls -1t "$BACKUP_DIR"/rules-learned.*.md 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | while IFS= read -r OLD_BACKUP; do
  rm -f "$OLD_BACKUP"
done

OUTPUT=""

# Cargar perfil — validar JSON con jq empty antes de usar
# (si corrupto → warn + defaults, nunca romper la sesión)
ALIAS="Nico"
LOCATION="España"
TONE="friday"
if jq empty "$PROFILE_FILE" >/dev/null 2>&1; then
  ALIAS=$(jq -r '.user.alias // "Nico"' "$PROFILE_FILE" 2>/dev/null || echo "Nico")
  LOCATION=$(jq -r '.user.location // "España"' "$PROFILE_FILE" 2>/dev/null || echo "España")
  TONE=$(jq -r '.preferences.tone_default // "friday"' "$PROFILE_FILE" 2>/dev/null || echo "friday")
else
  echo "[KAREN-RULES] WARN: profile.json corrupto (JSON inválido) — usando defaults Nico/España/friday" >&2
fi

OUTPUT+="<karen-profile>
Usuario: $ALIAS · $LOCATION
Tono default: $TONE
Profile completo: $PROFILE_FILE
</karen-profile>

"

# Cargar reglas aprendidas
if [ -f "$RULES_FILE" ]; then
  # grep -c imprime "0" Y sale con 1 si no hay matches → no usar "|| echo 0"
  # (duplicaría el valor: "0\n0"); default solo si la variable queda vacía
  RULES_COUNT=$(grep -c "^## " "$RULES_FILE" 2>/dev/null || true)
  [ -z "$RULES_COUNT" ] && RULES_COUNT=0

  OUTPUT+="<reglas-aprendidas>
Reglas activas en memoria ($RULES_COUNT entradas). Cúmplelas SIEMPRE.

$(cat "$RULES_FILE")
</reglas-aprendidas>

"
fi

# Output al stdout para inyección al system prompt
if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT"
fi

exit 0
