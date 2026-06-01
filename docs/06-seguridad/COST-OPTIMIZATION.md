# COST OPTIMIZATION — Karen barata

> Cómo Karen minimiza coste API + Claude Code créditos sin perder capacidad.

---

## Principios

1. **Modelo correcto para tarea correcta** — Haiku para extraction, Opus solo críticos.
2. **Prompt caching agresivo** — 90% ahorro reads cacheados.
3. **Memoria > re-leer** — Mem0 + profile.json antes fetch fresh.
4. **Docs pesados → Markdown** — 60-80% ahorro tokens.
5. **Context isolation subagents** — no heredar main context.
6. **Budget hard caps** — bloquear runaway costs.

---

## 1. Model routing — Haiku/Sonnet/Opus

### Tarifas 2026 (USD por 1M tokens)

| Model | Input | Output | Cached read | Mejor para |
|---|---|---|---|---|
| **Haiku 4.5** | $1 | $5 | $0.10 | Extraction, classification, simple-edit |
| **Sonnet 4.6** | $3 | $15 | $0.30 | Code, review, research medium |
| **Opus 4.7** | $15 | $75 | $1.50 | Deep reasoning, sparring, decisiones críticas |

**Ratio Opus/Haiku = 15x.** Routing correcto = ahorro masivo.

### Routing automático Karen

Ver `templates/.claude/lib/cost_optimizer.py` — `TASK_TO_MODEL` dict.

| Task | Modelo |
|---|---|
| extract_entities, classify_email, summarize_short | **Haiku** |
| code_write, code_review, research_medium, morning_brief | **Sonnet** |
| architecture_decision, sparring_finance, sparring_health, deep_research | **Opus** |

### Cuándo routing manual override

- Nico marca `--critical` → fuerza Opus.
- Nico marca `--cheap` → fuerza Haiku (con disclaimer "puede degradar calidad").

---

## 2. Prompt caching — 90% reduction

### Cómo funciona

Quote Anthropic: bloques >1024 tokens cacheados durante 5 min (default) o 1 hora (beta).

**Cache hit = 10% del precio normal lectura.**

### Aplicación Karen

| Bloque | Cache eligible | Frecuencia uso |
|---|---|---|
| `CLAUDE.md` raíz | ✅ ~2k tokens | Cada turno |
| `docs/01-quien-soy/PERFIL_NICO.md` | ✅ ~1.5k tokens | Cada turno |
| `docs/02-personalidad-karen/IDENTIDAD.md` | ✅ ~2k tokens | Cada turno |
| `rules-learned.md` | ✅ ~1k-5k tokens (crece) | Cada turno |
| `profile.json` | ❌ <500 tokens | Cada turno |
| Memoria dominio (>5 entries) | ✅ ~2k+ tokens | Cuando dominio activo |

### Cómo Karen marca cache

En el prompt al modelo, Karen añade `cache_control: {type: "ephemeral"}` a estos bloques. Cache hits visibles en `cost-log.jsonl` campo `cached_tokens`.

### Ahorro real ejemplo

Sesión típica 1h, 30 turnos:
- Sin caching: $5.20
- Con caching agresivo: $0.75 (~85% ahorro)

---

## 3. Memory-first — evitar re-leer

### Patrón

```
Nico pregunta algo.
  ↓
should_use_memory_instead(query)?
  ↓
  SI → query Mem0 + Graphiti
    ↓
    ¿Confianza > umbral?
      SÍ → responde con cita memoria
      NO → fetch fresh + actualiza memoria
  NO → fetch fresh
```

### Triggers memory-first (regex)

- "¿Qué/cuál/cómo... es/son mi/mis...?"
- "¿Recuerdas/sabías/conoces...?"
- "Según mi memoria..."
- `/memoria <X>`, `/recall <X>`

### Anti-pattern memory-first

- Datos temporales (precios bolsa, news hoy, agenda hoy) — siempre fresh.
- Cuando memoria stale (>6 meses) — verify antes de actuar.

---

## 4. Doc → Markdown conversion

### Multiplicador tokens (raw vs markdown)

| Formato | Multiplicador |
|---|---|
| PDF | ~4x |
| docx | ~3.5x |
| pptx | ~5x |
| xlsx | ~4.5x |
| HTML | ~2x |
| Markdown | 1x (baseline) |

### Tooling

```bash
# Instalar markitdown (Microsoft)
pip install markitdown

# Convertir
markitdown manual.pdf > manual.md
markitdown spec.docx > spec.md
markitdown data.xlsx > data.md
```

### Hook auto-convert (opcional)

```bash
# templates/.claude/hooks/auto-md-convert.sh
# PreToolUse Read si file >100kb y extensión pesada
```

Trigger: si Karen va a leer PDF/docx grande → sugerir convert + cachear.

### Ahorro real

PDF 2.5MB:
- Raw: ~250k tokens. Sonnet input cost: **$0.75**.
- Markdown: ~60k tokens. Cost: **$0.18**.
- **Ahorro: $0.57 (76%).**

---

## 5. Context isolation — subagents

### Patrón

Cuando `karen-orchestrator` delega a `karen-finance`:
- ❌ MAL: heredar full conversation context (incluye dev + research + agenda).
- ✅ BIEN: pasar SOLO task + memoria finanzas + 200 tokens contexto relevante.

### Ahorro

Sesión 50k tokens context. Si subagent hereda todo:
- karen-finance call: 50k input.
- Con isolation: 5k input.
- **Ahorro: 90% por subagent call.**

### Configuración

Cada subagent JSON tiene `context_isolation: true` (default). Sólo pasa via Task tool lo necesario.

---

## 6. Budget hard caps

### Configuración

`~/.claude/karen/budget.json`:
```json
{
  "session_max_usd": 5.00,
  "daily_max_usd": 20.00,
  "monthly_max_usd": 300.00,
  "alert_at_pct": 80,
  "block_opus_at_pct": 100
}
```

### Enforcement

- **Pre-call hook:** verifica budget restante antes cada API call.
- Si >80% → warning Nico.
- Si 100% → bloquea Opus calls, fuerza Haiku.
- Si 120% → bloquea TODAS llamadas hasta Nico extiende.

### Logging

`~/.claude/karen/cost-log.jsonl` append-only:
```jsonl
{"ts":"2026-06-15T14:32Z","model":"sonnet-4-6","input":12500,"output":850,"cached":8200,"cost_usd":0.0265,"session_total":0.34}
```

### Reporte
```
/karen-cheap-mode status
```

---

## 7. Tooling cost-aware

### Skill `markitdown` (built-in)
Convert docs pesados antes leer.

### Skill `compress` (caveman plugin)
Comprimir prompts/output ~75% tokens.

### Skill `caveman` (eficiencia tokens)
Modo terse para sesiones largas.

### Skill `handoff`
Pasar context entre sesiones sin re-leer todo.

---

## 8. Anti-patterns coste

❌ Usar Opus para extraction simple.
❌ NO cachear bloques >1024 tokens estables (CLAUDE.md, rules-learned).
❌ Leer PDF directo sin convert si >50kb.
❌ Cada turno cargar full memoria todos dominios.
❌ Subagents heredando full main context.
❌ Sin budget cap (runaway risk).
❌ Hallucination en `/karen-cheap-mode` activado (Haiku errores caros corregir).

---

## 9. Schedule cost optimization

### Diario
- Auto-cache estáticos al boot.
- Budget tracking continuo.

### Semanal
- Stop hook domingo: report top 5 expensive sessions.
- Identifica patrones derrochadores.

### Mensual
- Audit cost-log.jsonl completo.
- Ajustar `TASK_TO_MODEL` si patterns nuevos.

---

## 10. Estimación ahorro Karen v2.2 vs Karen ingenua

Sesión típica diaria (30 turnos, 1h):

| Estrategia | Sin opt | Con opt | Ahorro |
|---|---|---|---|
| Routing Opus → Haiku tasks simples | $5.20 | $1.80 | 65% |
| Prompt caching estáticos | $1.80 | $0.45 | 75% |
| Memory-first | $0.45 | $0.30 | 33% |
| Doc → MD convert | $0.30 | $0.18 | 40% |
| Context isolation subagents | $0.18 | $0.10 | 44% |

**Total ahorro: $5.20 → $0.10 (98%).**

Mensual: ~$150 → ~$3.

---

## Bibliografía

- [Anthropic — Prompt Caching docs](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching)
- [Anthropic — Pricing](https://www.anthropic.com/pricing)
- [Microsoft — markitdown GitHub](https://github.com/microsoft/markitdown)
- [Claude Code — Cost optimization patterns](https://docs.claude.com/en/docs/claude-code/best-practices)
