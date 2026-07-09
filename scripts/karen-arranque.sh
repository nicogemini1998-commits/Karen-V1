#!/usr/bin/env bash
# Briefing de arranque de Karen — se inyecta al contexto al abrir el proyecto (hook SessionStart).
# Ligero: nada de builds. Solo estado para que Karen proponga el siguiente paso.
ROOT="/Users/nicoopenclow/Desktop/karen asistente"
echo "=== KAREN · arranque $(date '+%Y-%m-%d %H:%M') ==="

# Proyecto activo
echo "• Control-Day: 02-DEV/proyectos-activos/control-day (Next.js, login OAuth + plasma orb)"

# Git
cd "$ROOT" 2>/dev/null && echo "• Git: rama '$(git branch --show-current 2>/dev/null)', $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') cambios sin commitear"

# KANZV en Obsidian
KZ="$ROOT/10-GRAPHIFY/KANZV-COUTURE"
if [ -d "$KZ" ]; then
  echo "• KANZV: volcado ($(find "$KZ" -name '*.md' 2>/dev/null | wc -l | tr -d ' ') docs en Obsidian)"
else
  echo "• KANZV: sin volcar"
fi

# ¿Export nuevo de KANZV sin procesar?
NEW=$(ls -t "$HOME"/Downloads/*ExportBlock*.zip 2>/dev/null | head -1)
[ -n "$NEW" ] && echo "  ⚠ Export en Descargas: $(basename "$NEW") — ¿/sync-kanzv?"

# ¿Chrome CDP abierto?
curl -s --max-time 2 http://localhost:9222/json/version >/dev/null 2>&1 && echo "• Navegador CDP: ACTIVO en :9222 (lectura en vivo disponible)"

echo "→ Revisa lo anterior y propón el siguiente paso antes de esperar instrucciones."
