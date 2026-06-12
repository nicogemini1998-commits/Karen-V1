# MEMORIA — Sistema persistente + Graphify

> Cómo Karen recuerda entre sesiones, organizada por dominio.

---

## Capas de memoria

### Capa 1 — Archivos markdown por dominio `[IMPL ✅ v1]`
Vive en `01-MEMORIA/<dominio>/<tipo>_<slug>.md`. Texto plano, leíble por humanos y Karen. Junto con el índice `MEMORY.md` y los hot facts (`profile.json`), es la base implementada de v1.

### Capa 2 — Graphify knowledge graph `[IMPL ✅ v1 — skill /graphify]`
Vive en `10-GRAPHIFY/graph.json`. Grafo de entidades + relaciones + comunidades. Ingesta automática tras decisión importante.

### Capa 3 — Memoria built-in Claude Code `[IMPL ✅ v1]`
`~/.claude/projects/<proyecto>/memory/MEMORY.md`. Auto-actualizada por skill memoria nativa.

**Karen Personal usa las 3 en paralelo.** Capa 1 = source of truth. Capa 2 = búsqueda + relaciones. Capa 3 = quick context boot.

### Capas siguientes `[v2 🔨]`
- **Mem0 semántico (MCP wrapper)** — el server self-hosted ya tiene template (`templates/docker-compose.memory.yml`). **`mem0_client.py` disponible para ingest manual/scripted desde v1.1** (`templates/.claude/lib/mem0_client.py`); MCP wrapper `mcp__mem0__*` v2.
- **Graphiti temporal (Neo4j)** — grafo bi-temporal `valid_from`/`valid_to`. v2. Detalle: [MEMORY-STACK.md](./MEMORY-STACK.md).

### Flujo real hoy (v1.1)
1. Decisión cerrada → markdown en `01-MEMORIA/<dominio>/AAAA-MM-DD_<tipo>_<slug>_v1.md` con frontmatter.
2. Actualizar índice `01-MEMORIA/MEMORY.md`.
3. (Opcional, si el stack memoria está up) ingest scripted:
   ```bash
   python3 .claude/lib/mem0_client.py add --domain finanzas \
     --metadata '{"type":"decision","date":"2026-06-15"}' \
     "Decisión: abrir cuenta Trade Republic"
   ```

---

## Reglas inviolables

### 1. Aislamiento por dominio
- `01-MEMORIA/dev/` NO se mezcla con `01-MEMORIA/finanzas/`.
- Karen no devuelve resultados cross-dominio salvo Nico pida explícito: "busca en finanzas Y salud".

### 2. Etiquetado obligatorio
Toda entrada lleva metadata al inicio:

```markdown
---
domain: finanzas
type: decision
date: 2026-06-15
tags: [etf, broker, trade-republic]
related: [research_etf-vanguard-vwce_v1.md]
---

# Decisión: abrir cuenta Trade Republic

...
```

### 3. Selectiva agresiva dentro de cada dominio
- NO guardar info derivable de código / archivos / git.
- NO guardar tareas en progreso (eso es TodoWrite).
- SÍ guardar decisiones cerradas con razón.
- SÍ guardar preferencias estables.
- SÍ guardar incidentes / aprendizajes.

### 4. Verificar antes de actuar sobre memoria stale
Si memoria dice "uso broker X" y Nico está actuando como si usara Y → preguntar antes.

### 5. Graphify ingest tras decisión importante
```
/graphify ingest 01-MEMORIA/finanzas/2026-06-15_DECISION_broker-trade-republic_v1.md --namespace finanzas
```

---

## Tipos de memoria

| Tipo | Cuándo guardar | Ejemplo |
|---|---|---|
| `profile` | Datos base de Nico estables | `profile_broker.md` |
| `preference` | Cómo prefiere recibir cosas | `preference_codigo-sin-comentarios.md` |
| `decision` | Decisión cerrada con razón | `decision_etf-vwce-50pct.md` |
| `incident` | Algo que falló, aprendizaje | `incident_deploy-leadup-fallo-rsync.md` |
| `research` | Investigación con conclusiones | `research_uranium-etfs-2026.md` |
| `reference` | Pointer a info externa | `reference_grafana-dashboards.md` |

---

## Índice MEMORY.md

`01-MEMORIA/MEMORY.md` es **solo índice**. No contiene contenido.

Formato:

```markdown
# MEMORY.md — Karen Personal (Índice)

## Perfil base (cross-dominio)
- [Perfil Nico](perfil_nico.md)
- [Estilo colaboración](estilo_colaboracion.md)

## DEV
- [Stack personal](dev/profile_stack.md)
- [Decisión: monorepo vs polirepo](dev/decision_monorepo_2026-06.md)

## FINANZAS
- [Perfil riesgo](finanzas/profile_riesgo.md)
- [Broker actual](finanzas/profile_broker.md)
- [Research nuclear ETFs](finanzas/research_nuclear-etfs-2026-05.md)

## SALUD
(vacío inicial)

## PRODUCTIVIDAD
(vacío inicial)

## APRENDIZAJE
(vacío inicial)

## RELACIONES
(vacío inicial)

## HOBBIES
(vacío inicial)

## COMPRAS-RESEARCH
(vacío inicial)
```

---

## Graphify — knowledge graph

### Namespaces por dominio

```bash
/graphify init --namespace dev
/graphify init --namespace finanzas
/graphify init --namespace salud
/graphify init --namespace productividad
/graphify init --namespace aprendizaje
/graphify init --namespace relaciones
/graphify init --namespace hobbies
/graphify init --namespace compras-research
/graphify init --namespace cross   ← solo para perfil base Nico
```

### Ingest típico

```bash
# Ingestar archivo individual
/graphify ingest 01-MEMORIA/finanzas/2026-06-15_DECISION_broker.md --namespace finanzas

# Ingestar carpeta completa
/graphify ingest 01-MEMORIA/finanzas/ --namespace finanzas --recursive
```

### Queries

```bash
# Query namespace específico
/graphify query "qué decisiones tomé sobre brokers" --namespace finanzas

# Query cross-namespace (solo si Nico pide)
/graphify query "qué research hice sobre AI" --namespace dev,finanzas,aprendizaje
```

### Auto-ingest

Hook PostToolUse opcional: tras edit en `01-MEMORIA/<X>/*` → ingest automático en namespace `<X>`. Ver `templates/.claude/hooks/auto-graphify-ingest.sh`.

---

## Flujo típico de memoria

### Escenario: Nico decide invertir en ETF nuclear

1. **Research previo:**
   - Karen invoca `deep-research` + `bigdata-com:sector-analysis`.
   - Output → `01-MEMORIA/finanzas/2026-06-15_RESEARCH_nuclear-etfs_v1.md`.
   - Etiqueta `domain: finanzas, type: research`.

2. **Sparring socrático:**
   - Karen no recomienda directo.
   - Pregunta sobre horizonte, % allocation, tolerancia drawdown.
   - Nico articula criterios.

3. **Decisión cerrada:**
   - Nico decide.
   - Karen escribe `01-MEMORIA/finanzas/2026-06-15_DECISION_uranium-3pct_v1.md`.
   - Etiqueta `domain: finanzas, type: decision`. Link a research previo.

4. **Graphify ingest:**
   - Auto vía hook → namespace finanzas.

5. **Index update:**
   - Karen añade entrada en `01-MEMORIA/MEMORY.md` sección FINANZAS.

6. **Sesión siguiente:**
   - Karen carga `MEMORY.md` al boot.
   - Si Nico pregunta "qué tengo en uranio?" → query Graphify namespace finanzas → respuesta con citación archivo + fecha.

---

## Decay y actualización

### Memoria stale
- Memoria con `date` >6 meses → marcar como `stale: true` en frontmatter.
- Antes de actuar sobre memoria stale → verificar contra realidad actual (Nico, archivos, web).

### Limpieza periódica
- Cada trimestre: revisar `01-MEMORIA/<dominio>/` y archivar lo obsoleto en `01-MEMORIA/<dominio>/99-archivo/`.
- Graphify reingest para limpiar.

---

## Privacidad

- **Todo en `01-MEMORIA/` está gitignored.**
- Solo `.gitkeep` + `MEMORY.md` (índice sin contenido sensible) suben al repo.
- Graphify graph.json también gitignored.
- Si Nico exporta a tercero (Notion, etc.): que sea explícito.
