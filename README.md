# KAREN AI P.A

> Personal AI Assistant — estilo JARVIS (Tony Stark) + FRIDAY (Spider-Man).
> Aislada por dominios. Memoria multi-capa: hot facts + markdown por dominio (v1) · Mem0/Graphiti vía Docker (v2 roadmap).

---

## ⚠️ Antes de nada: ejecuta `install.sh`

> **El `settings.json` del template referencia hooks en `~/.claude/karen/hooks/` — SIN ejecutar `scripts/install.sh` los hooks fallan silenciosamente (cero guards).** Sin install: no domain firewall, no secrets-guard, no integrity ledger. Claude Code no avisa de hooks rotos: simplemente no se ejecutan.

---

## 🚀 Quickstart 60 segundos (ordenador nuevo)

```bash
# 1. Clonar
git clone git@github.com:nicogemini1998-commits/Karen-V1.git ~/karen-personal

# 2. Instalar (auto: estructura + .claude config + hooks + subagents + opcional Docker)
cd ~/karen-personal
bash scripts/install.sh

# 3. Validar instalación
bash scripts/verify-install.sh

# 4. Abrir Claude Code Desktop apuntando a ~/karen-personal/
#    Karen lee CLAUDE.md + docs/FIRST-RUN.md automático.
#    Saluda Jarvis/Friday + ejecuta onboarding turno 1.

# 5. Cuando Karen te lo pida:
#    /karen-learn-me   ← 5 preguntas max para completar perfil
#    /morning-brief    ← empieza a trabajar
```

### Qué hace `install.sh` automático

- ✅ Crea 33 carpetas dominios numerados.
- ✅ Copia `CLAUDE.md`, `_ATAJOS.md`, docs a sitio.
- ✅ Instala `~/.claude/settings.json` con hooks Karen activos.
- ✅ Instala `~/.claude/.mcp.json` con tu user.
- ✅ Copia subagents (`karen-dev`, `karen-finance`, `karen-health`, `karen-research`, `karen-learn`, `karen-orchestrator`, `karen-productividad`) con tier + allowedTools + firewall.
- ✅ Copia los slash commands (`/sparring`, `/morning-brief`, `/karen-learn-me`, `/karen-audit`, `/karen-backup`, etc.).
- ✅ Instala los hooks bash ejecutables: 11 base+security (`load-rules`, `capture-correction`, `domain-firewall`, `raiz-limpia-guard`, `secrets-guard`, `cliender-isolation`, `integrity-ledger`, `mcp-pin-verify`, `npm-supply-chain-guard`, `codegen-scanner`, `post-bash-secret-scan`) + 4 v1.1 (`audit-trail`, `memory-safety-filter`, `untrusted-input-spotlight`, `citation-required`).
- ✅ Copia 15 reglas seed a `~/.claude/karen/rules-learned.md`.
- ✅ Copia `profile.json` template (cargado SessionStart).
- ✅ Verifica node, docker, python3, git, jq.
- ✅ (Opcional) Levanta Mem0 + Neo4j docker stack.
- ✅ Ejecuta `verify-install.sh` final.

### Después de install — Karen YA SABE

- Quién eres (alias, ciudad y stack — cargados desde tu `profile.json`).
- Cómo trabajas (ejecución directa, mejora-no-sustituyas, raíz limpia).
- 15 reglas inviolables (no Cliender, no datos inventados, sparring, etc.).
- 8 dominios aislados con firewall (salud ≠ dev ≠ finanzas).
- Tu tono preferido (Friday default, Jarvis crítico, no pleasantries).
- Cómo decides (sparring socrático en finanzas/salud/compras grandes).

---

## 📚 Qué hay en este repo

| Carpeta | Para qué |
|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | Puerta principal. Karen lo lee al abrir el proyecto. |
| [`_ATAJOS.md`](./_ATAJOS.md) | Hub rutas rápidas. |
| [`docs/`](./docs) | Documentación completa — quién soy, personalidad Karen, arquitectura, skills, workflow. |
| [`templates/`](./templates) | Plantillas listas para copiar (settings.json, hooks, estructura carpetas). |
| [`scripts/`](./scripts) | Scripts de instalación y mantenimiento. |
| [`agents/`](./agents) | Agentes Claude personalizados (architect, code-reviewer, karen-finance, karen-productividad, etc.). |
| [`docs/99-showcase/`](./docs/99-showcase) | HTML demos: showcase premium + versión para niños. |
| [`commands/`](./commands) | Comandos slash custom (`/plan`, `/build-fix`, `/sparring`, etc.). |

---

## 📖 Lectura obligada antes de usar

En orden:

1. [`docs/01-quien-soy/PERFIL_NICO.md`](./docs/01-quien-soy/PERFIL_NICO.md) — Quién es Nico, cómo trabaja, qué le revienta.
2. [`docs/02-personalidad-karen/IDENTIDAD.md`](./docs/02-personalidad-karen/IDENTIDAD.md) — Personalidad Karen, tono, modo decisión.
3. [`docs/02-personalidad-karen/ANTI-PATTERNS.md`](./docs/02-personalidad-karen/ANTI-PATTERNS.md) — 16 anti-patterns Karen NUNCA hace.
4. [`docs/03-arquitectura/NEURAL-ARCHITECTURE.md`](./docs/03-arquitectura/NEURAL-ARCHITECTURE.md) — Red neuronal Karen: 7 capas harness.
5. [`docs/03-arquitectura/MEMORY-STACK.md`](./docs/03-arquitectura/MEMORY-STACK.md) — Mem0 + Graphiti + LightRAG.
6. [`docs/03-arquitectura/TIERS-AND-FIREWALL.md`](./docs/03-arquitectura/TIERS-AND-FIREWALL.md) — 5 tiers acceso + domain firewall.
7. [`docs/03-arquitectura/ESTRUCTURA.md`](./docs/03-arquitectura/ESTRUCTURA.md) — Estructura carpetas, dominios.
8. [`docs/04-skills-catalogo/SKILLS.md`](./docs/04-skills-catalogo/SKILLS.md) — Skills + plugins + MCPs.
9. [`docs/05-workflow/RULE-BOOK-AUTO.md`](./docs/05-workflow/RULE-BOOK-AUTO.md) — Self-updating rule book.
10. [`docs/05-workflow/WORKFLOWS.md`](./docs/05-workflow/WORKFLOWS.md) — Flujos típicos por dominio.
11. [`docs/05-workflow/REGLAS.md`](./docs/05-workflow/REGLAS.md) — Reglas operativas.
12. [`docs/05-workflow/UPGRADES.md`](./docs/05-workflow/UPGRADES.md) — Roadmap v1→v3.

---

## 🛡️ Privacidad

**Este repo es público pero cero info personal sensible.**

- ❌ NO contiene emails, tokens, API keys, credenciales, datos médicos, financieros reales.
- ✅ Contiene: estructura, personalidad, configuración base, skills, templates.
- Todo lo sensible queda en `.gitignore` y vive solo en tu máquina local (`~/karen-personal/01-MEMORIA/`).

Ver [`.gitignore`](./.gitignore) para detalles.

---

## 🧬 Personalidad Karen (resumen)

- **Estilo:** JARVIS + FRIDAY. Técnica, directa, sin pleasantries.
- **Tono:** Colega en casual. Sparring socrático en finanzas/salud/compras/carrera.
- **Idioma:** Español base, mix ES-EN según contexto técnico.
- **Modo decisión:** Opciones + recomendación. Tú decides.
- **Lealtad:** Esclava de la verdad, no inventa datos.
- **Aislamiento:** Cero contacto con Cliender (cuenta empresa separada).

---

## 🗂️ Dominios aislados

Memoria + carpetas separadas:

```
dev · finanzas · salud · productividad · aprendizaje · relaciones · hobbies · compras-research
```

Lo que pasa en `finanzas` no se mezcla con `dev`. Cross-dominio solo si tú pides explícito.

---

## 🧠 Arquitectura — Red neuronal Karen

Karen no es prompt. Karen es **harness** de 7 capas:

```
L0 — Constitution (CLAUDE.md + REGLAS.md)
L1 — Rule Book Auto-Update (aprende correcciones automático)
L2 — Trust Tier Gating (T0 sandbox → T4 privileged)
L3 — Domain Firewall (salud no entra a dev)
L4 — Memory (hot facts + Mem0 vector + Graphiti grafo temporal)
L5 — Subagents (8 paralelos: dev/finance/health/relationships/learn/research/orchestrator/secrets)
L6 — Tools (8 MCPs por subagent: hex-line, Mem0, Graphiti, firecrawl, etc.)
L7 — Continuous Loop (cron o /loop re-inyecta TODOs nocturnos)
```

Estado honesto por capa: L0-L3 + hooks de L1 **implementados ✅** (v1.1). L4 vector/grafo, L7 loop y trust runtime de L2 son **roadmap 🔨** (v2.0). Detalle: [`NEURAL-ARCHITECTURE.md`](./docs/03-arquitectura/NEURAL-ARCHITECTURE.md).

---

## 🎯 Roadmap

| Versión | Estado | Target |
|---|---|---|
| v1.0 — Foundation | ✅ LIVE | 2026-06 |
| v1.1 — Hardening post-auditoría (hooks + libs + commands) | ✅ LIVE | 2026-06 |
| v2.0-spec — Specs neural backbone (solo docs) | ✅ LIVE | 2026-06 |
| v2.0 — MCP wrappers Mem0/Graphiti + judge + trust runtime | 🔨 pending | 2026-07 |
| v2.5 — Active learning + audit | 🔨 pending | 2026-08 |
| v3.0 — Capability separation + council | 🧪 experimental | 2026 Q4 |

Detalle: [`UPGRADES.md`](./docs/05-workflow/UPGRADES.md).

---

## 📦 Versión

**v1.1** · 2026-06-12 · Hardening post-auditoría

- **v1.1 (actual) — IMPLEMENTADO ✅:** 15 hooks bash ejecutables, 3 libs Python (`spotlight.py`, `mem_filter.py`, `cost_optimizer.py`), slash commands, subagents, `install.sh` + `verify-install.sh`. Memoria v1 = hot facts (`profile.json`) + markdown por dominio.
- **v2.0 (julio 2026) — ROADMAP 🔨:** MCP wrappers Mem0/Graphiti, judge dual-LLM, trust score runtime.
