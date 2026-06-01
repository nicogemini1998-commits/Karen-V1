# KAREN AI P.A

> Personal AI Assistant — estilo JARVIS (Tony Stark) + FRIDAY (Spider-Man).
> Aislada por dominios. Memoria persistente con Graphify.

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
- ✅ Copia 6 subagents (`karen-dev`, `karen-finance`, `karen-health`, `karen-research`, `karen-learn`, `karen-orchestrator`) con tier + allowedTools + firewall.
- ✅ Copia 10 slash commands (`/sparring`, `/morning-brief`, `/karen-learn-me`, etc.).
- ✅ Instala 6 hooks bash ejecutables (`load-rules`, `capture-correction`, `domain-firewall`, `raiz-limpia-guard`, `secrets-guard`, `cliender-isolation`).
- ✅ Copia 15 reglas seed a `~/.claude/karen/rules-learned.md`.
- ✅ Copia `profile.json` template (cargado SessionStart).
- ✅ Verifica node, docker, python3, git, jq.
- ✅ (Opcional) Levanta Mem0 + Neo4j docker stack.
- ✅ Ejecuta `verify-install.sh` final.

### Después de install — Karen YA SABE

- Quién eres (Nico, Sagunto, stack TS+Next+Python+Docker).
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
| [`agents/`](./agents) | Agentes Claude personalizados (architect, code-reviewer, finanzas-sparring, etc.). |
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
L7 — Continuous Loop (Stop hook re-inyecta TODOs nocturnos)
```

Detalle: [`NEURAL-ARCHITECTURE.md`](./docs/03-arquitectura/NEURAL-ARCHITECTURE.md).

---

## 🎯 Roadmap

| Versión | Estado | Target |
|---|---|---|
| v1.0 — Foundation | ✅ LIVE | 2026-06 |
| v2.0-spec — Specs neural backbone | ✅ LIVE | 2026-06 |
| v2.0 — Mem0+Graphiti+hooks impl | 🔨 pending | 2026-07 |
| v2.5 — Active learning + audit | 🔨 pending | 2026-08 |
| v3.0 — Capability separation + council | 🧪 experimental | 2026 Q4 |

Detalle: [`UPGRADES.md`](./docs/05-workflow/UPGRADES.md).

---

## 📦 Versión

**v2.0-spec** · 2026-06-01 · Neural Backbone Spec
