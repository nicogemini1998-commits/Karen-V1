# TIERS & DOMAIN FIREWALL — Acceso progresivo

> Karen no tiene acceso total día 1. Tiers crecen con uso + confianza.
> Inspirado: Microsoft Agent Governance Toolkit (Abril 2026) + Pipelock + WorkOS auth.

---

## Filosofía

**Quote SOTA:** *"Many early agent deployments fail by giving agents too much access — an agent that only needs to summarize project updates should not also be able to edit permissions, delete records, or export sensitive data."*

Karen empieza pequeña. Gana acceso conforme demuestra fiabilidad. Pierde acceso si rompe reglas críticas.

---

## 5 Tiers

### T0 — Sandbox (experimental)

**Para qué:** subagents nuevos, skills no probados, research libre.

**Permisos:**
- Read-only filesystem.
- Sin Bash.
- Sin MCP writes.
- Sin red externa.

**Subagents ejemplo:** `karen-experimental`, `karen-test-skill`.

---

### T1 — Daily (uso diario)

**Para qué:** trabajo dev, research, learning.

**Permisos:**
- RW project files.
- Bash allowlist específica (`npm`, `git status/diff/log`, `ls`, `mkdir`, `docker compose`).
- Mem0 read + write (con domain filter).
- Red allowlist dominios (`github.com`, `npmjs.com`, `anthropic.com`, etc.).

**Subagents ejemplo:** `karen-dev`, `karen-research`, `karen-learn`.

**Trust score requerido:** >300/1000.

---

### T2 — Sensitive (dominios privados)

**Para qué:** finanzas, salud, relaciones.

**Permisos:**
- RW vault privado encrypted (`~/karen-personal/01-MEMORIA/<dominio>/`).
- NUNCA escribe OneDrive shared / Drive shared.
- Sin red externa por defecto.
- Citation-required mode ON.

**Subagents ejemplo:** `karen-finance`, `karen-health`, `karen-relationships`.

**Trust score requerido:** >500/1000 + override manual primer uso.

---

### T3 — Operational (Cliender / deploys)

**Para qué:** cuenta empresa Cliender, side projects con deploy.

**Permisos:**
- Full project access.
- Deploy SSH (key autenticada).
- APIs externas OAuth-scoped.
- Confirmación explícita antes acción destructiva.

**Subagents ejemplo:** `karen-cliender` (en cuenta empresa, no esta), `karen-deploy`.

**Trust score requerido:** >700/1000.

**Nota Karen Personal:** este tier en cuenta personal solo para side projects propios. Cliender NUNCA toca esta cuenta.

---

### T4 — Privileged (one-shot crítico)

**Para qué:** rotación secretos, billing, decisiones legales.

**Permisos:**
- One-shot per session.
- Requiere confirmación humana explícita.
- Audit log en `01-MEMORIA/audit/<AAAA-MM-DD>_<accion>.md`.
- Sin acceso a otros tiers durante la operación.

**Subagents ejemplo:** `karen-secrets-rotation`.

**Trust score requerido:** N/A (always requires human confirm).

---

## Domain Firewall

### Reglas de aislamiento

```yaml
firewall_rules:
  karen-dev:
    tier: T1
    allow_paths:
      - "01-MEMORIA/dev/**"
      - "02-DEV/**"
      - "06-APRENDIZAJE/notas-research/**"
    deny_paths:
      - "01-MEMORIA/finanzas/**"
      - "01-MEMORIA/salud/**"
      - "01-MEMORIA/relaciones/**"
      - "03-FINANZAS/**"
      - "04-SALUD-FITNESS/**"
      - "07-RELACIONES/**"
    allow_network:
      - "github.com"
      - "npmjs.com"
      - "docs.anthropic.com"
      - "docs.python.org"
      - "context7.com"
    allow_mcp:
      - "hex-line"
      - "memory"
      - "context7"
      - "firecrawl"
      - "github"

  karen-finance:
    tier: T2
    allow_paths:
      - "01-MEMORIA/finanzas/**"
      - "03-FINANZAS/**"
    deny_paths:
      - "01-MEMORIA/{dev,salud,relaciones,productividad}/**"
      - "02-DEV/**"
      - "04-SALUD-FITNESS/**"
      - "07-RELACIONES/**"
    allow_network: []  # default ninguna
    allow_network_temporary:  # solo per-session con /karen-grant
      - "trade-republic.com"
      - "bigdata.com"
    allow_mcp:
      - "hex-line"
      - "memory" (scope: finanzas)
      - "graphiti" (namespace: finanzas)
      - "bigdata-com"
      - "deep-research"
    citation_required: true

  karen-health:
    tier: T2
    allow_paths:
      - "01-MEMORIA/salud/**"
      - "04-SALUD-FITNESS/**"
    deny_paths:
      - "01-MEMORIA/{dev,finanzas,relaciones,productividad}/**"
      - "02-DEV/**"
      - "03-FINANZAS/**"
      - "07-RELACIONES/**"
    allow_network: []
    allow_mcp:
      - "hex-line"
      - "memory" (scope: salud)
      - "graphiti" (namespace: salud)
      - "deep-research"
    citation_required: true
    medical_disclaimer: true  # auto-añadir disclaimer no-médico
```

### PreToolUse hook firewall

```bash
#!/usr/bin/env bash
# ~/.claude/karen/hooks/firewall.sh

INPUT="$(cat)"
SUBAGENT="$(echo "$INPUT" | jq -r '.subagent_name // "main"')"
TOOL="$(echo "$INPUT" | jq -r '.tool_name')"
TOOL_INPUT="$(echo "$INPUT" | jq -r '.tool_input')"

# Cargar reglas firewall del subagent
RULES="$HOME/.claude/karen/firewall/$SUBAGENT.yaml"
[ ! -f "$RULES" ] && echo "$INPUT" && exit 0

# Verificar path access
if [ "$TOOL" = "Read" ] || [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
  FILE_PATH="$(echo "$TOOL_INPUT" | jq -r '.file_path // .path')"

  # Check deny_paths
  for pattern in $(yq '.deny_paths[]' "$RULES"); do
    if [[ "$FILE_PATH" == $pattern ]]; then
      echo "BLOCKED: subagent $SUBAGENT tier prohibits access to $FILE_PATH" >&2
      exit 2
    fi
  done
fi

# Verificar MCP allowlist
if [[ "$TOOL" == mcp__* ]]; then
  MCP_NAME="$(echo "$TOOL" | cut -d_ -f3)"
  if ! yq ".allow_mcp[]" "$RULES" | grep -q "$MCP_NAME"; then
    echo "BLOCKED: MCP $MCP_NAME no permitido para subagent $SUBAGENT" >&2
    exit 2
  fi
fi

echo "$INPUT"
```

---

## Trust Score System

### Inicialización
Cada subagent empieza en 100/1000.

### Eventos +score
- Tarea completada sin corrección Nico: +5.
- Tarea completada con thanks/positive Nico: +10.
- 7 días sin violación regla: +20.

### Eventos -score
- Corrección Nico tipo "no, X mal": -10.
- Violación regla `severity: high`: -50.
- Hallucination factual detectada: -30.
- Sycophancy detectada: -15.

### Tier upgrade automático
- Score >300 + 30 días uso: T0 → T1.
- Score >500 + 60 días + 0 violaciones high: T1 → T2 (con confirm Nico).
- Score >700 + 90 días + audit pass: T2 → T3 (con confirm Nico).

### Tier downgrade automático
- Violación regla `high`: tier -1 inmediato.
- 3 hallucinations en una semana: tier -1.
- Score <100: T0 forzado.

### Trust log
`~/.claude/karen/trust-log.jsonl`

```json
{"timestamp":"2026-06-15T14:32","subagent":"karen-finance","event":"correction_received","delta":-10,"new_score":485,"reason":"sugirió compra sin sparring previo"}
{"timestamp":"2026-06-16T09:15","subagent":"karen-dev","event":"task_completed","delta":+5,"new_score":312}
```

---

## Grant temporal

Cuando Nico quiere expandir permisos por una sesión:

```
/karen-grant network --domain bigdata.com --subagent karen-finance --duration 1h
/karen-grant write --mcp gmail --duration session
```

Hook valida + autoriza + log:
```json
{"timestamp":"2026-06-15T15:00","grant":"network","target":"bigdata.com","subagent":"karen-finance","expires":"2026-06-15T16:00","granted_by":"nico-confirm"}
```

Expirado el tiempo → revoke automático.

---

## Auditoría

### Mensual
- Review `trust-log.jsonl` → ver tendencias por subagent.
- Listar tiers actuales + score actuales.
- Identificar subagents underused (deprecate).

### Trimestral
- Audit completo violaciones rules `high`.
- Backup `rules-learned.md` + `trust-log.jsonl`.

### Comando review
```
/karen-audit
```

Output:
```
SUBAGENT          TIER  SCORE  ÚLTIMA-VIOLACIÓN  USO-7D
karen-dev         T1    520    nunca             34 tasks
karen-finance     T2    485    2026-06-15        12 tasks
karen-health      T2    310    2026-05-30        3 tasks
karen-research    T1    640    nunca             21 tasks
karen-learn       T1    280    2026-06-10        5 tasks

⚠ karen-finance: -10 hoy (corrección). Revisar si trend.
⚠ karen-learn: bajo score, considerar retraining seed memoria.
```
