# NEURAL ARCHITECTURE — Red Neuronal Karen

> Karen no es prompt. Karen es **harness**: capas memoria + runtime + safety wrapping un modelo.
> Quote SOTA 2026: *"The Harness Is the Moat."* Inversión va en harness, no prompt.

---

## Diagrama mental

```
┌────────────────────────────────────────────────────────────────┐
│                        KAREN HARNESS                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  L0 — CONSTITUTION (este CLAUDE.md + REGLAS.md)          │  │
│  │  Identidad, valores, reglas inviolables (8)              │  │
│  └──────────────────────────────────────────────────────────┘  │
│           ↓                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  L1 — RULE BOOK AUTO-UPDATE (self-learning)              │  │
│  │  ~/.claude/karen/rules-learned.md                        │  │
│  │  Cada corrección Nico → regla nueva auto-añadida         │  │
│  └──────────────────────────────────────────────────────────┘  │
│           ↓                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  L2 — TRUST TIER GATING (T0-T4)                           │  │
│  │  Por subagent: allowed tools, network, domains            │  │
│  └──────────────────────────────────────────────────────────┘  │
│           ↓                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  L3 — DOMAIN FIREWALL (PreToolUse hook)                   │  │
│  │  Salud no entra a dev. Finanzas no entra a relaciones.    │  │
│  └──────────────────────────────────────────────────────────┘  │
│           ↓                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  L4 — MEMORY (3 capas)                                    │   │
│  │  ┌─────────────┬─────────────┬───────────────────────┐   │   │
│  │  │ Hot facts   │ Semantic    │ Knowledge Graph        │   │   │
│  │  │ (JSON)      │ (Vector)    │ (Graphiti temporal)    │   │   │
│  │  │ profile.    │ Mem0 /      │ Entidades + relaciones │   │   │
│  │  │ json        │ Chroma      │ con valid_from/to      │   │   │
│  │  └─────────────┴─────────────┴───────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│           ↓                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  L5 — SUBAGENTS (paralelo)                                │  │
│  │  karen-dev | karen-finance | karen-health |               │  │
│  │  karen-relationships | karen-learn | karen-orchestrator   │  │
│  └──────────────────────────────────────────────────────────┘  │
│           ↓                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  L6 — TOOLS (MCPs + plugins)                              │  │
│  │  hex-line · Mem0 · Graphiti · firecrawl · context7 ·      │  │
│  │  Gmail · Calendar · Notion · GitHub · Playwright          │  │
│  └──────────────────────────────────────────────────────────┘  │
│           ↓                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  L7 — CONTINUOUS LOOP (Stop hook)                         │  │
│  │  Re-injecta TODOs pendientes → fresh context.             │  │
│  │  Filesystem = state durable.                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
                            ↑
              ┌─────────────┴─────────────┐
              │   CLAUDE OPUS / SONNET    │
              │   (modelo, intercambiable) │
              └───────────────────────────┘
```

### Estado real por capa (post-v1.1)

| Capa | Estado |
|---|---|
| **L0 — Constitution** (identidad) | ✅ v1 |
| **L1 — Rule book auto-update** | ✅ v1.1 — hooks `capture-correction.sh` + `load-rules.sh` |
| **L2 — Trust tiers** | config ✅ · enforcement runtime 🔨 |
| **L3 — Domain firewall** | ✅ best-effort — `domain-firewall.sh` |
| **L4 — Memory** | markdown + hot facts ✅ · vector (Mem0) / graph (Graphiti) 🔨 v2 — ingest manual ya posible vía `mem0_client.py` |
| **L5 — Subagents** | ✅ v1 — roster en `agents/` |
| **L6 — Tools (MCPs)** | ✅ base (`.mcp.json`) · Mem0/Graphiti MCP custom 🔨 v2 |
| **L7 — Continuous loop** | audit ✅ v1.1 — `audit-trail.sh` · loop overnight 🔨 |

---

## L0 — Constitution `[✅ v1]`

`CLAUDE.md` + `docs/05-workflow/REGLAS.md`. Capa inmutable. Editable solo con aprobación explícita Nico.

Contiene:
- Identidad (Jarvis + Friday).
- 8 reglas inviolables.
- Modo decisión por dominio.
- Tono base.

**No cambia por sesión.**

---

## L1 — Rule Book Auto-Update (Self-Learning) `[✅ v1.1 — capture-correction.sh + load-rules.sh]`

### Path
`~/.claude/karen/rules-learned.md`

### Mecanismo
Stop hook captura correcciones explícitas Nico durante sesión:
- "no, esto no" / "te dije que no" / "deja de hacer X" / "siempre X" / "nunca Y"

→ Auto-append a `rules-learned.md` con timestamp + contexto.

### Carga
SessionStart hook inyecta `rules-learned.md` al system prompt cada nueva sesión.

### Formato entrada
```markdown
## 2026-06-15 14:32 — Regla: nunca usar Apollo
**Contexto:** Karen sugirió integración Apollo en LeadUp.
**Corrección Nico:** "ya te dije, Apollo NO se usa, leads vienen de Lusha".
**Regla activa:** No mencionar Apollo en contexto LeadUp / leads.
**Severidad:** alta.
```

### Por qué importa
Quote SOTA: *"The Feedback Layer passes trajectories through strict, rule-based verification gates, and if work is rejected, captures the correction and dynamically commits it to memory as an active rule constraint."*

Karen aprende sin que Nico tenga que re-escribir reglas.

---

## L2 — Trust Tier Gating (T0-T4) `[config ✅ · enforcement runtime 🔨]`

Inspirado Microsoft Agent Governance Toolkit + WorkOS authorization patterns.

### Tiers

| Tier | Subagent ejemplo | Tools | Network | Riesgo |
|---|---|---|---|---|
| **T0 — Sandbox** | `karen-experimental` | Read-only fs, sin Bash, sin MCP writes | Bloqueado | Mínimo |
| **T1 — Daily** | `karen-dev`, `karen-research`, `karen-learn` | RW project files, Bash allowlist, Mem0 read | Allowlist dominios | Bajo |
| **T2 — Sensitive** | `karen-finance`, `karen-health`, `karen-relationships` | RW vault privado encrypted, NUNCA escribe OneDrive shared | Ninguna red externa | Medio |
| **T3 — Operational** | `karen-cliender` (separado cuenta empresa) | Full project + deploy SSH + APIs externas | OAuth scoped | Alto |
| **T4 — Privileged** | `karen-secrets-rotation` | One-shot, requiere confirm humano + log audit | Audited | Crítico |

### Implementación
- `.claude/agents/<name>/settings.json` con `allowedTools` + `permissions.deny`.
- PreToolUse hook verifica subagent name vs tier asignado, bloquea tools fuera allowlist.
- Trust score 0-1000 por subagent: log outcomes, ascenso tier gated.

---

## L3 — Domain Firewall `[✅ best-effort — domain-firewall.sh]`

PreToolUse hook que bloquea:
- Subagent `karen-health` queryeando memoria `01-MEMORIA/finanzas/`.
- Subagent `karen-cliender` accediendo `01-MEMORIA/salud/`.
- Cualquier subagent T1/T2 accediendo memoria fuera dominio salvo flag `--cross-domain` explícito.

### Reglas firewall
```yaml
firewall:
  karen-dev:
    allow: [01-MEMORIA/dev/*, 02-DEV/*]
    deny: [01-MEMORIA/{finanzas,salud,relaciones}/*]

  karen-finance:
    allow: [01-MEMORIA/finanzas/*, 03-FINANZAS/*]
    deny: [01-MEMORIA/{salud,relaciones,dev}/*, 02-DEV/*]

  karen-health:
    allow: [01-MEMORIA/salud/*, 04-SALUD-FITNESS/*]
    deny: [01-MEMORIA/{finanzas,relaciones,dev}/*]
```

---

## L4 — Memory (3 capas) `[markdown + hot facts ✅ · vector/graph 🔨 v2]`

### L4a — Hot Facts (key-value)
**Path:** `~/.claude/karen/profile.json`

```json
{
  "user": {
    "alias": "YOUR-NAME",
    "location": "YOUR-CITY, YOUR-COUNTRY",
    "timezone": "Europe/Madrid",
    "github": "YOUR-GITHUB-USERNAME",
    "languages": ["es", "en"]
  },
  "current_focus": {
    "active_projects": ["karen-personal"],
    "this_week_priorities": []
  },
  "preferences": {
    "tone_default": "friday",
    "tone_critical": "jarvis",
    "code_comments": "minimal",
    "naming_format": "AAAA-MM-DD_TIPO_slug_vN.ext"
  },
  "last_updated": "2026-06-01T13:00:00Z"
}
```

Carga: SessionStart hook lee + inyecta resumen 200 chars al system prompt.

### L4b — Semantic Memory (Vector)
**Backend:** Mem0 self-hosted o Chroma local.
**Contenido:** embeddings de cada archivo `01-MEMORIA/<dominio>/*.md`.
**Query:** semantic search por dominio + cross-dominio (con permiso).

**Quote SOTA Mem0:** *"+29.6 on temporal queries, +23.1 on multi-hop"* (mejoras algoritmo Abril 2026).

**Instalación:**
```bash
pip install mem0ai
# o (template real del repo)
docker compose -f templates/docker-compose.memory.yml up -d
```

Wrapping en MCP server para que Karen lo use vía `mcp__mem0__*` `[v2 🔨]`. Hoy (v1.1): ingest manual/scripted con `templates/.claude/lib/mem0_client.py` (`add`/`search`/`delete`/`health`).

### L4c — Knowledge Graph (Temporal)
**Backend:** Graphiti (Zep) o LightRAG.
**Por qué Graphiti:** edges bi-temporales (`valid_from`/`valid_to`). Karen sabe NO SOLO qué dijo Nico SINO cuándo lo dijo y si sigue vigente.

**Entidades típicas:**
- `Person` (Nico, contactos)
- `Project` (side projects, no-Cliender)
- `Decision` (con timestamp + dominio)
- `Tool` (broker, app, librería)
- `Goal` (financiero, salud, aprendizaje)

**Edges típicos:**
- `decided_at(timestamp)`
- `replaced_by(timestamp)` — antiguo broker → nuevo broker
- `blocks` — decisión A bloquea acción B
- `depends_on`
- `domain_owns` — qué dominio "posee" entidad

**Quote SOTA:** *"Zep knows not just what you said but when you said it."*

**Por qué Karen necesita esto:**
Nico dice "uso Trade Republic" en Marzo. En Junio cambia a otro. Mem0 puede confundir. Graphiti edge: `Nico —[uses, valid: 2026-03 to 2026-06]→ TradeRepublic`, `Nico —[uses, valid: 2026-06 to NULL]→ NuevoBroker`. Query "qué broker usa Nico" → NuevoBroker. Query "qué broker usaba en Mayo" → TradeRepublic. Sin confusión.

### Estrategia híbrida (vector + grafo)
- Mem0: facts simples ("Nico vive en Madrid").
- Graphiti: relaciones temporales ("Nico cambió de X a Y en fecha Z").
- LightRAG (opcional): retrieval graph-aware sobre carpetas numeradas (65-80% ahorro tokens vs full GraphRAG).

---

## L5 — Subagents `[✅ v1 — roster en agents/]`

Cada uno con personalidad + tier + tools propios.

### Roster Karen v2

| Subagent | Tier | Personalidad | Tools |
|---|---|---|---|
| `karen-orchestrator` | T1 | Friday casual, distribuidor | Task (fan-out) |
| `karen-dev` | T1 | Senior dev mode | hex-line, code-review, e2e, build-fix |
| `karen-finance` | T2 | Sparring socrático financiero | bigdata-com:*, deep-research, Mem0 finanzas |
| `karen-health` | T2 | Coach + disclaimer médico | deep-research, Mem0 salud |
| `karen-relationships` | T2 | Empática, drafts mensajes | copywriting, humanize |
| `karen-learn` | T1 | Tutor Feynman + spaced rep | deep-research, doc-coauthoring |
| `karen-research` | T1 | Multi-fuente verificada | firecrawl, brightdata, deep-research |
| `karen-secrets` | T4 | Rotación segura, audit log | una vez por sesión, confirm humano |

### Carga paralela
**Quote SOTA:** *"Subagents and MCP connections initialize in parallel, cutting startup time significantly."* (Abril 2026)

8 subagents sin penalización cold-start.

---

## L6 — Tools (MCPs + Plugins) `[✅ base — .mcp.json · Mem0/Graphiti MCP 🔨 v2]`

### Stack mínimo Karen v2

| Tool | Para qué | Tier permitido |
|---|---|---|
| `hex-line` | File ops hash-verified | T1+ |
| `mem0` (custom MCP) | Memoria semántica | T1+ por dominio |
| `graphiti` (custom MCP) | Knowledge graph temporal | T1+ |
| `firecrawl` | Web search + scrape | T1+ |
| `context7` | Docs librerías al día | T1+ |
| `playwright` | Browser automation | T1+ |
| `github` | Repos personales | T1+ scope `repo` mínimo |
| `gmail` | Email personal | T2 scoped `gmail.readonly` default |
| `google-calendar` | Calendar personal | T2 `calendar.readonly` default |
| `notion` | Notes second brain | T2 |
| `bigdata-com:*` | Research financiero | T2 |

### Regla MCPs activos
**Quote SOTA:** *"Running 5–8 servers simultaneously is fine, but running 20+ starts to introduce startup latency and potential instability."*

Cap: **8 MCPs activos por subagent.** Resto on-demand.

### OAuth scoping mínimo
**Quote SOTA:** *"You can scope credentials precisely, and you should not just request all available scopes because it's easier."*

Default todo MCP write-capable → read-only. Flip a write solo en sesión activa con `/karen-grant write <mcp>`.

---

## L7 — Continuous Loop (Stop Hook) `[audit ✅ v1.1 — audit-trail.sh · loop overnight 🔨]`

### Patrón
**Quote SOTA:** *"A hook that intercepts the model's attempt to exit and re-injects the original prompt into a fresh context window, forcing the agent to continue against a completion goal."*

### Aplicación Karen
- Stop hook lee `01-MEMORIA/TODO.md`.
- Si hay tareas pendientes con flag `karen-can-do-overnight: true` → re-inicia con tarea como prompt.
- Resultados → `01-MEMORIA/<dominio>/AAAA-MM-DD_overnight_<slug>.md`.
- Filesystem = durable state entre iteraciones.

### Casos uso típicos
- Research deep multi-fuente que tarda horas.
- Indexing Mem0 + Graphiti de cambios día.
- Resumen semanal automático cada domingo 23:00.

---

## Resumen mental — Karen como sistema operativo

```
Modelo Claude = CPU
L0-L1 = BIOS (firmware identidad)
L2 = Privilege rings (CPU)
L3 = Firewall (network)
L4 = Memoria RAM + Disco + caché
L5 = Procesos (subagents paralelos)
L6 = Drivers (MCPs hablando con hardware)
L7 = Cron / systemd (background daemon)
```

Karen no es un chat. Karen es un OS personal que usa Claude como motor de razonamiento.

---

## Cómo evoluciona Karen

1. **Capa L1 (rule book)** crece automática con uso.
2. **Capa L4 (memoria)** crece con cada decisión + research.
3. **Capa L5 (subagents)** se añaden conforme nuevos dominios aparecen.
4. **Capas L0, L2, L3** cambian solo con aprobación explícita Nico.
5. **Capa L6 (tools)** se actualiza cuando MCPs nuevos salen.

Versionado: `CHANGELOG.md` documenta upgrade por capa.

---

## Próximo paso si quieres reforzar Karen aún más

- **Capability separation** (Pipelock pattern): split Karen en "brain process" (sin red) + "tool proxy" (con red, sin secretos). Tráfico escaneado en boundary.
- **Multi-perspective council** para decisiones críticas: skeptic + optimist + domain expert debaten antes de output.
- **Harness-evolver loop**: Karen itera autónomamente sobre sus propios prompts usando regression evals contra golden set conversaciones pasadas.

Ver `docs/05-workflow/UPGRADES.md` roadmap.
