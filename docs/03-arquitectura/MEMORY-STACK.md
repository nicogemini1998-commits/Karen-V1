# MEMORY STACK — Mem0 + Graphiti + LightRAG

> Cómo Karen recuerda en 2026. Híbrido vector + grafo temporal + hot facts.
>
> **Estado:** markdown por dominio + índice `MEMORY.md` + hot facts `profile.json` `[IMPL ✅ v1]` · Mem0 MCP wrapper + Graphiti temporal `[v2 🔨]`. **`mem0_client.py` disponible para ingest manual/scripted desde v1.1** (`templates/.claude/lib/mem0_client.py`); MCP wrapper v2.

---

## Por qué 3 capas

Quote SOTA Mem0 2026: *"In 2026, memory is treated as a dedicated architectural component separate from the model's context window, not just a longer prompt."*

Single store (solo vector o solo grafo) falla:
- Solo vector: pierde temporalidad. ¿"Qué broker uso?" devuelve los 3 que mencioné en distintos momentos.
- Solo grafo: lento para queries semánticas open-ended.
- Solo files markdown: no escala, no soporta multi-hop queries.

Solución: **3 capas con responsabilidades claras.**

---

## L4a — Hot Facts (JSON key-value) `[IMPL ✅ v1]`

### Para qué
Datos estables, leídos siempre al boot.

### Path
`~/.claude/karen/profile.json`

### Estructura
```json
{
  "user": {
    "alias": "YOUR-NAME",
    "location": "YOUR-CITY, YOUR-COUNTRY",
    "timezone": "Europe/Madrid",
    "languages": ["es", "en"],
    "github": "YOUR-GITHUB-USERNAME"
  },
  "preferences": {
    "tone_default": "friday",
    "tone_critical": "jarvis",
    "code_comments": "minimal",
    "naming_format": "AAAA-MM-DD_TIPO_slug_vN.ext",
    "decision_mode_finance": "socratic_sparring",
    "decision_mode_health": "options_with_disclaimer"
  },
  "active_domains": [
    "dev", "finanzas", "salud", "productividad",
    "aprendizaje", "relaciones", "hobbies", "compras-research"
  ],
  "current_focus": {
    "this_week": [],
    "blocked_on": []
  },
  "last_updated": "2026-06-01T13:00:00Z"
}
```

### Cuándo se actualiza
- SessionStart hook lee + inyecta resumen.
- PostToolUse hook actualiza `current_focus` cuando Nico anota prioridades.
- Nico edita directo cuando preferencia cambia.

---

## L4b — Semantic Memory (Mem0) `[v2 🔨 — MCP wrapper]`

### Para qué
Búsqueda fuzzy de facts ("¿qué pensé sobre uranium ETFs?"). Embeddings.

### Stack
- **Self-hosted Mem0** (gratis, control total).
- Docker: template real en `templates/docker-compose.memory.yml` — server FastAPI inline sobre `python:3.12-slim`, puerto `127.0.0.1:8888`.
- **Hoy (v1.1):** ingest manual/scripted vía `templates/.claude/lib/mem0_client.py` (`add` / `search` / `delete` / `health`, stdlib puro, cero deps).
- **v2 🔨:** custom MCP wrapper `mcp__mem0__add`, `mcp__mem0__search`, `mcp__mem0__delete`.

### Instalación
```bash
# Stack completo (Mem0 + Neo4j) desde el template real
docker compose -f templates/docker-compose.memory.yml up -d

# Smoke test
python3 templates/.claude/lib/mem0_client.py health
```

### Scopes (3 niveles Mem0)
| Scope | Para qué | Karen uso |
|---|---|---|
| `user` | Cross-sesión, persistente | Default |
| `session` | Solo sesión actual | Conversación temp |
| `agent` | Compartido entre subagents | Perfil base Nico |

### Schema entrada
```python
{
    "memory": "Nico prefiere Trade Republic para tickets pequeños",
    "user_id": "nico",
    "metadata": {
        "domain": "finanzas",
        "type": "preference",
        "date": "2026-06-01",
        "source_file": "01-MEMORIA/finanzas/2026-06-01_PREFERENCE_broker_v1.md",
        "tags": ["broker", "retail-es"]
    }
}
```

### Domain filtering
Query siempre incluye `metadata.domain = <X>` salvo cross-dominio explícito.

---

## L4c — Knowledge Graph (Graphiti) `[v2 🔨]`

### Para qué
Relaciones + temporalidad. ¿"Qué broker usa Nico AHORA"? ¿"Qué decisiones tomó sobre ETFs en Q1 2026"?

### Por qué Graphiti vs LightRAG vs Microsoft GraphRAG

| Sistema | Bi-temporal | Ingest cost | Query speed | Karen fit |
|---|---|---|---|---|
| Graphiti (Zep) | ✅ (`valid_from`/`valid_to`) | Medio | Rápido | ⭐ Default |
| LightRAG | ❌ | Bajo (65-80% ahorro vs GraphRAG) | Rápido | Bueno para indexing carpetas |
| Microsoft GraphRAG | ❌ | Alto | Lento | Overkill personal |

**Recomendación:** Graphiti primario, LightRAG opcional para carpetas grandes.

### Stack
```bash
pip install graphiti-core neo4j
# Neo4j ya viene en el template (karen-neo4j, bolt 127.0.0.1:7687):
docker compose -f templates/docker-compose.memory.yml up -d neo4j
```

### Entidades + relaciones típicas

**Entidades:**
- `Person` — Nico, contactos
- `Project` — side projects
- `Decision` — con timestamp + dominio
- `Tool` — broker, app, librería, MCP
- `Goal` — objetivos por dominio
- `Resource` — libro, curso, paper, ETF

**Relaciones bi-temporales:**
- `uses(valid_from, valid_to)` — Nico usa Trade Republic
- `replaced_by(at)` — Trade Republic replaced_by NuevoBroker en fecha X
- `decided(at, domain)` — Decision X tomada at Y
- `blocks` — Decision A bloquea Action B
- `depends_on`
- `domain_owns` — Entidad pertenece a dominio

### Query ejemplo
```python
# "qué broker usa Nico AHORA"
graphiti.search(
    "broker actual Nico",
    filter_temporal={"valid_at": "now"}
)
# → NuevoBroker (no TradeRepublic obsoleto)

# "qué brokers usó Nico históricamente"
graphiti.search(
    "brokers Nico",
    filter_temporal={"any_time": True}
)
# → [TradeRepublic (2026-03..2026-06), NuevoBroker (2026-06..)]
```

---

## Auto-extraction pipeline `[v2 🔨]`

### PostToolUse hook (entity extraction)
Tras cada sesión:

1. Lee output sesión.
2. Llama Haiku 4.5 con prompt extracción entities + relations:
```
Extrae entidades + relaciones de esta conversación.
Formato JSON: {"entities": [...], "relations": [...]}.
Solo si confianza > 0.7.
```
3. Upsert a Mem0 + Graphiti.
4. Update `~/.claude/karen/profile.json` si cambia preferencia estable.

### Modelo barato para extracción
Quote SOTA: *"Few-shot prompting with GPT-4 or Claude achieves accuracy roughly equivalent to — and sometimes superior to — fully supervised traditional models."*

Haiku 4.5 = suficiente. Opus reservado para razonamiento principal.

---

## Citation-required mode

### Regla
Todo claim factual sobre Nico/dominios → cita memoria source.

### Implementación
PreToolUse hook intercepta output con regex `\b(Nico|tu|tus)\b` + claim factual.
Si falta `[source: <path>]` → bloquea + pide a Karen citar.

### Ejemplo correcto
> "Tu broker actual es Trade Republic [source: 01-MEMORIA/finanzas/2026-06-01_DECISION_broker_v1.md]. ¿Sigues con ese o cambió?"

### Ejemplo incorrecto (bloqueado)
> "Te recomiendo seguir con Trade Republic porque va bien."  ← sin source, sin sparring

### Cuando NO aplicar
- Discusión técnica general no-personal.
- Outputs código sin claim sobre Nico.
- Sparring (preguntas, no afirmaciones).

---

## Anti-staleness — decay management

### Memoria stale
- Entrada con `date >6 meses` → marcar `stale: true` frontmatter.
- Antes actuar sobre stale → verificar realidad actual.

### Limpieza periódica
```bash
# Mensual (Stop hook domingo 23:00)
/graphify rebuild --namespace <dominio>

# Trimestral (manual)
karen review-stale --domain finanzas
```

---

## Privacidad capas

| Capa | Local | Cloud OK? | Encrypted? |
|---|---|---|---|
| Hot facts (`profile.json`) | ✅ | ❌ | Filesystem perms |
| Mem0 semántico | ✅ | ❌ (self-hosted) | Disk encryption recommended |
| Graphiti / Neo4j | ✅ | ❌ | Neo4j auth + disk |
| Markdown files `01-MEMORIA/` | ✅ | ❌ (gitignored) | Disk encryption |

**T2 dominios** (finanzas, salud, relaciones): nunca salen del laptop. Mem0 + Graphiti separados con encryption at rest si Nico quiere paranoia extra.

---

## Performance budgets

| Operación | Target |
|---|---|
| Boot session (load hot facts + summary) | <500ms |
| Mem0 search single domain | <200ms |
| Graphiti temporal query | <500ms |
| LightRAG retrieval over 1000 docs | <1s |
| Entity extraction Haiku post-session | <3s |

---

## Integraciones con Karen workflow

### Cuando Karen escribe memoria

**Flujo real hoy (v1.1):**
```
1. Usuario decide algo importante.
2. Karen escribe markdown 01-MEMORIA/<dominio>/AAAA-MM-DD_<tipo>_<slug>_v1.md
3. Actualizar MEMORY.md índice.
4. (Opcional, si el stack memoria está up) ingest scripted:
   python3 .claude/lib/mem0_client.py add --domain <dominio> "<texto>"
```

**Flujo objetivo v2 🔨 (hook automático):**
```
1-2 igual, y el PostToolUse hook hace:
   a. Upsert Mem0 con metadata.domain.
   b. Extract entities → Graphiti.
   c. Update profile.json si preference cambió.
```

### Cuando Karen consulta memoria
```
1. Usuario pregunta algo.
2. Subagent identifica dominio.
3. Query Mem0 filter domain.
4. Si pregunta temporal → query Graphiti.
5. Si necesita multi-hop → LightRAG retrieval.
6. Citation required en output.
```

---

## Roadmap Mem stack

| Versión | Capa | Estado |
|---|---|---|
| v1.0 | Markdown files + indice MEMORY.md | ✅ |
| v1.0 | + hot facts profile.json | ✅ (`templates/.claude/karen/profile.json`) |
| v1.1 | + `mem0_client.py` ingest manual/scripted (server en template compose) | ✅ |
| v2.0 | + Mem0 self-hosted MCP wrapper | 🔨 |
| v2.5 | + Graphiti Neo4j MCP | 🔨 (Neo4j ya en template compose) |
| v3.0 | + LightRAG indexing carpetas | experimental |
| v3.5 | + entity extraction auto Haiku | experimental |
