# UPGRADES ROADMAP — Karen v1 → v3

> Roadmap basado en research SOTA personal AI assistants 2026.
> Quote SOTA: *"The Harness Is the Moat."*

---

## v1.0 — Foundation (LIVE — Junio 2026)

### Implementado
- ✅ Estructura repo + carpetas dominios
- ✅ `CLAUDE.md` autoinstalable
- ✅ Docs: perfil, identidad, arquitectura, memoria, skills, workflows, reglas
- ✅ `install.sh` auto-instalación
- ✅ Templates `.claude/settings.json` + `.mcp.json`
- ✅ Agents: architect, code-reviewer, finanzas-sparring, salud-coach, learn-tutor
- ✅ Commands: sparring, dominio, agenda, memoria-add, portafolio, research
- ✅ `.gitignore` exhaustivo

### Limitaciones
- Memoria solo markdown (no semantic + temporal grafo).
- Sin self-updating rule book.
- Sin tier-gating real (todos subagents misma capacidad).
- Sin domain firewall enforcement.
- Citation no obligatoria.

---

## v2.0 — Neural Backbone (Target: Julio 2026)

### Tier 1 — Must-have

#### M1. Dual memory backend
- **Mem0 self-hosted** docker + MCP wrapper.
- **Graphiti + Neo4j** docker + MCP wrapper.
- Custom MCP `mcp__mem0__*` y `mcp__graphiti__*`.
- Migración data inicial: `01-MEMORIA/*` → upsert ambas capas.
- Hot facts `profile.json` cargado SessionStart.
- **Docs:** `docs/03-arquitectura/MEMORY-STACK.md` ✅

#### M2. Self-updating rule book
- Hook `capture-correction.sh` PreToolUse / user_message.
- Hook `load-rules.sh` SessionStart inyecta `rules-learned.md` al system prompt.
- Auto-extract reglas con Haiku 4.5.
- **Docs:** `docs/05-workflow/RULE-BOOK-AUTO.md` ✅
- Seed reglas iniciales (8 inviolables) precargadas.

#### M3. Tier-gated subagents
- 8 subagents nuevos con tier asignado.
- Per-subagent `.claude/agents/<name>/settings.json` con `allowedTools` + `permissions`.
- Trust score system + log.
- **Docs:** `docs/03-arquitectura/TIERS-AND-FIREWALL.md` ✅

#### M4. Domain firewall
- PreToolUse hook valida path access por subagent.
- Reglas firewall YAML por subagent.
- Logs violaciones.
- **Docs:** mismo doc TIERS-AND-FIREWALL.md.

#### M5. Citation-required mode
- Hook intercepta claims factuales sobre Nico sin source path.
- Bloquea + pide cite.
- **Docs:** `docs/02-personalidad-karen/ANTI-PATTERNS.md` ✅

#### M6. `/morning-brief` orchestration
- Fan-out paralelo subagents.
- Sintetiza digest único.
- **Docs:** `commands/morning-brief.md` ✅

### Tasks v2.0

```
[ ] Setup Docker compose: Mem0 + Neo4j
[ ] Build MCP wrappers Mem0 + Graphiti
[ ] Migrar 01-MEMORIA/* a Mem0 + Graphiti
[ ] Implementar capture-correction.sh
[ ] Implementar load-rules.sh
[ ] Seed rules-learned.md con 8 reglas inviolables
[ ] Crear .claude/agents/karen-{dev,finance,health,relationships,learn,research,orchestrator,secrets}/settings.json
[ ] Implementar trust score tracking
[ ] Implementar firewall.sh PreToolUse
[ ] Implementar citation hook
[ ] Crear /morning-brief subagent orchestration
[ ] Test end-to-end con conversación dummy
```

---

## v2.5 — Active Learning (Target: Agosto 2026)

### Tier 2 — Nice-to-have

#### N1. `/karen-learn-me` active learning
- Auditoría memoria + selección preguntas alta entropía.
- Max 5 preguntas / sesión.
- Auto-trigger cuando gaps críticos.
- **Docs:** `commands/karen-learn-me.md` ✅

#### N2. OAuth-scoped MCPs
- Gmail / Calendar / Outlook con scope mínimo.
- `/karen-grant write` para flip read→write per session.
- Auto-revoke end-session.
- **Docs:** `commands/karen-grant.md` ✅

#### N3. Anti-sycophancy hook
- Cada 20 turnos: inyectar "be skeptical" reminder.
- Métrica disagreement rate >5%.

#### N4. LightRAG indexing
- LightRAG sobre carpetas numeradas (`02-DEV/`, `06-APRENDIZAJE/`).
- 65-80% ahorro tokens vs full GraphRAG.
- Query graph-aware desde Karen.

#### N5. Trust-tier auto-upgrade
- Daemon revisa scores diario.
- Auto-propose upgrade Nico cuando threshold cumple.
- **Docs:** TIERS-AND-FIREWALL.md ✅

#### N6. `/karen-audit` weekly
- Auto cada domingo 23:00.
- Trust scores, violations, grants, sycophancy, stale memory.
- **Docs:** `commands/karen-audit.md` ✅

#### N7. Continuous loop background
- Stop hook re-inyecta TODOs pendientes `01-MEMORIA/TODO.md`.
- Re-inicia Karen en fresh context para work nocturno low-stakes.
- Filesystem = state durable.

### Tasks v2.5

```
[ ] Implementar /karen-learn-me con entropy scoring
[ ] OAuth scoping Gmail/Calendar (default read-only)
[ ] Implementar /karen-grant + revoke + log
[ ] Anti-sycophancy hook + métrica disagreement
[ ] Setup LightRAG indexing
[ ] Daemon trust score review
[ ] Implementar /karen-audit (semanal + manual)
[ ] Stop hook continuous loop con TODO.md
```

---

## v3.0 — Experimental Frontier (Target: Q4 2026)

### Tier 3 — Experimental

#### X1. Capability separation harness
- Split Karen: "brain process" (sin red, con secretos) + "tool proxy" (con red, sin secretos).
- Tráfico cross-boundary escaneado (Pipelock pattern).
- Mitigación prompt injection + data exfiltration.

#### X2. Multi-perspective council
- Decisiones críticas → 3 subagents debaten:
  - Skeptic: busca por qué NO.
  - Optimist: busca por qué SÍ.
  - Domain expert: contexto técnico.
- Síntesis Karen + recomendación con tradeoffs visibles.

#### X3. Harness-evolver loop
- Karen itera autónoma sobre sus propios prompts.
- Regression evals sobre golden set conversaciones pasadas.
- Self-tuning prompt cada N evaluaciones.

#### X4. Encrypted T2 vault
- Health/finance memoria nunca sale del laptop.
- Encryption at rest separate Mem0 instance.
- Decrypt-on-demand con touch ID / passphrase.

#### X5. Voice + ambient mode
- JARVIS-grade ambient capture.
- Khoj-style scheduled deep research jobs durante sueño.
- iOS Shortcuts trigger ambient mode.

#### X6. Cross-account sync (Personal ↔ Cliender boundary)
- Hot-line read-only desde Personal para ver agenda Cliender.
- NUNCA al revés (Cliender no ve Personal).
- Encrypted handoff archivos específicos cuando Nico autoriza.

### Tasks v3.0

```
[ ] Diseñar arquitectura capability separation
[ ] Implementar tool proxy con scanning boundary
[ ] Crear multi-perspective council orchestration
[ ] Setup regression eval harness
[ ] Encrypted vault T2 (libsodium o age)
[ ] Voice integration (Whisper local + iOS Shortcuts)
[ ] Cross-account boundary spec + impl
```

---

## v4.0 — Speculative (2027+)

### Lejano

- **Multi-modal**: Karen procesa imágenes screenshots Nico envía iOS automatic.
- **Predictive memory**: Karen sugiere preferencias antes que Nico pida (con anti-sycophancy guards).
- **Federated learning**: Karen aprende patrones generales sin que datos salgan local.
- **Self-modification**: Karen propone mejoras `CLAUDE.md` con justificación + diff.

---

## Métricas éxito por versión

| Métrica | v1 | v2 | v2.5 | v3 |
|---|---|---|---|---|
| Repeated corrections | baseline | -50% | -80% | -95% |
| Sycophancy rate | unknown | <10% | <5% | <3% |
| Hallucination factual | unknown | 0/week | 0/month | 0/quarter |
| Tier mismatches | N/A | manual | auto | auto |
| Time-to-answer simple | 5s | 3s | 2s | <1s |
| Domain firewall violations | N/A | logged | <1/week | <1/month |
| Privacy leak incidents | N/A | 0 | 0 | 0 |

---

## Cómo participo (Nico) en cada versión

### v2.0
- Aprueba cada subagent settings.json antes de activar.
- Confirma cada tier-up T2/T3.
- Review `rules-learned.md` mensual.

### v2.5
- Concedo grants explícitos cuando Karen pida (network, write).
- Hago `/karen-audit` semanal.

### v3.0
- Validate council outputs antes de aceptar.
- Audit harness-evolver changes en CLAUDE.md.

---

## Filosofía evolutiva

Cada upgrade Karen:
1. **Reduce fricción** repetir-correcciones / re-explicar.
2. **Aumenta confianza** medible (trust scores).
3. **Mantiene privacidad** estricta (anti-leak).
4. **Preserva autonomía** Nico (sparring, no authority transfer).

Si una versión rompe alguno → revert.

---

## Versioning

`CHANGELOG.md` documenta cada release.
Tag git por versión: `v1.0`, `v2.0`, etc.
Branch `main` = última stable. Branches `dev/v2.x` para iteración.
