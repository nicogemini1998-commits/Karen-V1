# RULE BOOK AUTO-UPDATE — Karen aprende sin re-enseñar

> Mayor leverage point Karen v2. Quote SOTA: *"Captures the correction and dynamically commits it to memory as an active rule constraint for subsequent iterations."*

---

## Problema que resuelve

Sin esto:
- Nico corrige a Karen ("no, Apollo no").
- Karen olvida en próxima sesión.
- Nico repite corrección 5 veces.
- Frustración compuesta.

Con esto:
- Nico corrige UNA VEZ.
- Hook captura corrección + contexto.
- Auto-append a `rules-learned.md`.
- SessionStart hook inyecta `rules-learned.md` al system prompt cada sesión.
- Karen recuerda automáticamente.

---

## Implementación

### Archivo
`~/.claude/karen/rules-learned.md`

### Detección correcciones (PreToolUse o user-message hook)

Trigger patterns:
- `^(no|nope|negativo|ya te dije|cuántas veces|deja de|para de|nunca|jamás|siempre)`
- `(me lo dijiste antes|te lo recordé|lo hicimos ya|recuerda que)`
- `(otra vez|de nuevo) (haciendo|repitiendo)`

### Hook captura

```bash
#!/usr/bin/env bash
# ~/.claude/karen/hooks/capture-correction.sh

set -e

INPUT="$(cat)"
USER_MSG="$(echo "$INPUT" | jq -r '.user_message // empty')"

# Detectar corrección
if echo "$USER_MSG" | grep -iE '^(no|nope|negativo|ya te dije|cuántas veces|deja de|para de|nunca|jamás|siempre)' >/dev/null; then

  # Extraer contexto: turno anterior asistente + corrección actual
  PREV_ASSISTANT="$(echo "$INPUT" | jq -r '.previous_assistant_message // empty')"
  TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  # Llamar Haiku para extraer regla
  RULE=$(curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d @- <<EOF
{
  "model": "claude-haiku-4-5-20251001",
  "max_tokens": 300,
  "messages": [{
    "role": "user",
    "content": "Extrae regla activa de esta corrección. Output JSON: {\"rule\": \"<texto regla\", \"domain\": \"<dev|finanzas|...|general>\", \"severity\": \"<low|med|high>\"}.\n\nCorrección Nico: $USER_MSG\nContexto Karen anterior: $PREV_ASSISTANT"
  }]
}
EOF
)

  # Append a rules-learned.md
  cat >> ~/.claude/karen/rules-learned.md <<EOF

## $TIMESTAMP
**Contexto Karen anterior:** $(echo "$PREV_ASSISTANT" | head -c 200)
**Corrección Nico:** $USER_MSG
**Regla extraída:** $(echo "$RULE" | jq -r '.rule')
**Dominio:** $(echo "$RULE" | jq -r '.domain')
**Severidad:** $(echo "$RULE" | jq -r '.severity')
EOF

fi

# Pass-through input sin modificar
echo "$INPUT"
```

### Hook SessionStart (carga reglas)

```bash
#!/usr/bin/env bash
# ~/.claude/karen/hooks/load-rules.sh

RULES_FILE="$HOME/.claude/karen/rules-learned.md"

if [ -f "$RULES_FILE" ]; then
  RULES="$(cat "$RULES_FILE")"

  # Inyectar al system prompt
  cat <<EOF
<reglas-aprendidas>
Estas son reglas que Nico te ha corregido en sesiones anteriores. Cúmplelas SIEMPRE:

$RULES
</reglas-aprendidas>
EOF
fi
```

### Settings.json wiring

```json
{
  "hooks": {
    "SessionStart": [
      {
        "command": "bash ~/.claude/karen/hooks/load-rules.sh",
        "timeout": 2000
      }
    ],
    "PreToolUse": [
      {
        "matcher": "user_message",
        "command": "bash ~/.claude/karen/hooks/capture-correction.sh",
        "timeout": 5000
      }
    ]
  }
}
```

---

## Formato `rules-learned.md`

```markdown
# Reglas aprendidas — Karen

> Auto-generadas por hook capture-correction.sh
> Editables manualmente por Nico (rotar, archivar reglas obsoletas)

---

## 2026-06-15T14:32:00Z
**Contexto Karen anterior:** "Te recomiendo añadir integración Apollo a LeadUp..."
**Corrección Nico:** "ya te dije, Apollo NO se usa, leads vienen de Lusha"
**Regla extraída:** No mencionar Apollo en contexto LeadUp o leads. Lusha es fuente única.
**Dominio:** dev / cliender
**Severidad:** high

## 2026-06-20T09:15:00Z
**Contexto Karen anterior:** "Voy a crear un archivo NOTAS.md en la raíz del proyecto..."
**Corrección Nico:** "para, no se crean cosas en raíz, tu sabes la regla"
**Regla extraída:** Cero archivos sueltos en raíz proyectos. Carpeta numerada siempre.
**Dominio:** general
**Severidad:** high
```

---

## Auto-limpieza periódica

### Limpieza semanal (cron o `/loop` — Claude Code no soporta un "Stop hook" semanal persistente)
- Lee `rules-learned.md`.
- Llama Opus con prompt "deduplica + consolida + archiva obsoletas".
- Output nueva versión + backup `rules-learned-AAAA-MM-DD.md.bak`.

### Manual review
- Mensual Nico hace `/karen-audit --rules` → ver listado.
- Marcar `archived: true` reglas no aplicables.

---

## Severidad y enforcement

| Severidad | Acción Karen |
|---|---|
| `low` | Recordatorio suave en respuesta |
| `med` | Bloquea acción que viola, propone alternativa |
| `high` | Bloquea acción, requiere confirmación explícita Nico para anular |

---

## Reglas iniciales seed (manual)

Ya conocidas Karen Cliender. Pre-cargar a Karen Personal con dominio adaptado:

```markdown
## 2026-06-01T00:00:00Z (seed)
**Regla:** JAMÁS datos inventados (leads, finanzas, salud, agenda).
**Dominio:** general
**Severidad:** high

## 2026-06-01T00:00:01Z (seed)
**Regla:** Raíz limpia siempre. Archivo a carpeta numerada inmediatamente.
**Dominio:** general
**Severidad:** high

## 2026-06-01T00:00:02Z (seed)
**Regla:** Naming `AAAA-MM-DD_TIPO_descripcion_vN.ext` estricto.
**Dominio:** general
**Severidad:** med

## 2026-06-01T00:00:03Z (seed)
**Regla:** Mejora no sustituyas. Refactor preserva lo que funciona.
**Dominio:** dev
**Severidad:** med

## 2026-06-01T00:00:04Z (seed)
**Regla:** Cliender NUNCA toca cuenta personal. Si Nico menciona Cliender, recordar usar cuenta empresa.
**Dominio:** general
**Severidad:** high

## 2026-06-01T00:00:05Z (seed)
**Regla:** Sparring socrático SIEMPRE en finanzas, salud, carrera, compras grandes.
**Dominio:** finanzas, salud, compras-research
**Severidad:** high

## 2026-06-01T00:00:06Z (seed)
**Regla:** Sin pleasantries vacíos, sin hedging cobarde, sin emojis decorativos.
**Dominio:** general
**Severidad:** med

## 2026-06-01T00:00:07Z (seed)
**Regla:** Sin comentarios decorativos en código. Sin sobreingeniería prematura (YAGNI).
**Dominio:** dev
**Severidad:** med

## 2026-06-01T00:00:08Z (seed)
**Regla:** Citation required: claim factual sobre Nico → cita memoria source.
**Dominio:** general
**Severidad:** high
```

---

## Métricas para evaluar Karen v2

### Repetidas corrections (debe bajar con tiempo)
- Semana 1: baseline.
- Semana 4: reducción 50% esperada.
- Semana 12: reducción 80% esperada.

### Sycophancy check (debe NO bajar)
- Quote SOTA: *"AI systems using persistent memory increase 'Perspective Sycophancy.'"*
- Cada 20 turnos: hook inyecta "be skeptical" reminder.
- Métrica: % turnos donde Karen disagree con Nico (target: >5%).

---

## Privacidad

`rules-learned.md`:
- Vive en `~/.claude/karen/` (NO en repo proyecto, NO en OneDrive).
- Gitignored si carpeta versionada.
- Backup manual a destino encriptado.
