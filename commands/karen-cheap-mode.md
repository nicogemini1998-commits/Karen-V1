---
description: Modo barato. Route tareas a Haiku, agresivo prompt caching, Markdown convert docs, evitar re-reads.
---

# /karen-cheap-mode

Activa modo eficiencia coste para sesión actual.

## Args

- `on` (default) — activa cheap mode.
- `off` — desactiva (volver a routing normal por criticidad).
- `status` — muestra coste actual sesión.
- `budget <USD>` — set hard cap presupuesto (ej. `5.00`).

## Comportamiento cheap mode ON

### 1. Model routing agresivo a Haiku
- Todo task posible → Haiku 4.5 ($1/$5 por 1M vs Opus $15/$75 = 15x ahorro).
- Sonnet solo si Haiku falla.
- Opus solo si Nico marca explícito "critical" o tarea en TASK_TO_MODEL whitelist (architecture_decision, sparring_finance, sparring_health, deep_research, complex_refactor).

### 2. Prompt caching agresivo
- Bloques >1024 tokens automáticamente cacheados (5min TTL default, 1h beta opcional).
- Cache hit = 10% del precio normal lectura.
- Karen marca explícito qué bloques cachea en context.

### 3. Convert docs pesados → Markdown
- PDF >100kb → markitdown convert antes leer.
- docx/xlsx/pptx → markdown.
- Ahorro típico: 60-80% tokens.

### 4. Memory-first
- Antes responder, Karen busca en Mem0 + profile.json.
- Solo si memoria insuficiente → fetch fresh.
- Output cita memory source path (ya parte de citation-required mode).

### 5. Context isolation por subagent
- Subagent NO hereda full main context — solo lo necesario del task.
- Ahorro: 30-50% tokens por subagent call.

### 6. Budget hard cap
- Default sesión: $5 USD.
- Track en `~/.claude/karen/cost-log.jsonl`.
- Al 80% budget → warning. Al 100% → bloquea calls Opus, fuerza Haiku.

## Comportamiento cheap mode OFF (normal)

Routing por criticidad:
- Tareas triviales → Haiku.
- Coding + research medio → Sonnet.
- Decisiones críticas → Opus.

Cache opcional, no agresivo.
Sin budget hard cap default.

## Output

### `/karen-cheap-mode on`
```
💰 CHEAP MODE: ON

Routing:
  Default model → haiku-4-5
  Sonnet/Opus → solo whitelist tasks

Prompt caching:
  Auto-cache blocks >1024 tokens

Doc conversion:
  PDF/docx/xlsx → markitdown antes leer

Memory-first:
  Mem0 + profile.json consultados antes fetch fresh

Budget hard cap:
  $5.00 USD (configura con /karen-cheap-mode budget <USD>)
  Spent actual: $0.00

Próxima llamada Opus disponible solo con flag --critical.
```

### `/karen-cheap-mode status`
```
💰 COST STATUS — sesión actual

Modelo más usado: haiku-4-5 (78%)
                  sonnet-4-6 (18%)
                  opus-4-7 (4%)

Llamadas totales: 47
Tokens input:     127,432 (de los cuales 89,300 cached = 70%)
Tokens output:    18,924
Coste sesión:     $0.34 USD
Cheap mode:       ON
Budget remaining: $4.66 / $5.00

Top tasks coste:
  1. /morning-brief         $0.12 (Sonnet)
  2. deep-research uranium  $0.08 (Sonnet)
  3. code-review proyecto X $0.05 (Sonnet)
  ...

Ahorro estimado vs sin cheap mode: $2.10 USD (~85%).
```

## Implementation (honesta — qué es automático y qué no)

El command ejecuta `~/.claude/scripts/karen-cheap-mode.sh`, que SOLO escribe el state file `~/.claude/karen/cheap-mode.json` (enabled, budget, flags de estrategias). A partir de ahí:

| Estrategia | ¿Quién la aplica? | ¿Enforcement? |
|---|---|---|
| Routing Haiku | Karen elige modelo al lanzar Tasks leyendo el state file | Convención — no hay switch duro |
| Prompt caching | API Anthropic (automático en blocks elegibles) | Sí, real |
| markitdown convert | **MANUAL** — Karen ejecuta `markitdown <file>` antes de leer si `md_convert: true`. NO hay hook que intercepte Reads de PDF; si Karen lo olvida, nadie lo fuerza | No |
| Memory-first | Convención de Karen en sesión | No |
| Context isolation | Diseño de los Task prompts | No |
| Budget hard cap | Tracking best-effort en `cost-log.jsonl`; el bloqueo al 100% lo aplica Karen, no un hook | Parcial |

Resumen honesto: cheap-mode es un **contrato de comportamiento** persistido en JSON, no un enforcement técnico. Lo único duro es el prompt caching (lado API) y el permiso `Bash(markitdown:*)` ya allowlisted en `settings.json`.

## Anti-patterns cheap mode

- ❌ Forzar Haiku en sparring socrático (calidad razonamiento crítico).
- ❌ Skip prompt caching cuando block <1024 tokens (no eligible).
- ❌ Convert PDF a markdown si <50kb (overhead conversion no compensa).
- ❌ Auto-disable Opus en domain finanzas/salud (sparring necesita razonamiento profundo).

## Schedule

Auto-on para:
- Subagents T1 daily tasks.
- Research libros / cursos / topics watch (sonnet adecuado).
- Drafts mensajes.

Auto-off para:
- Sparring finanzas/salud.
- Security audit code.
- Architecture decisions side projects.
- Deep research multi-fuente verificada adversarial.
