# CHANGELOG — KAREN AI P.A

> Histórico cambios. Semver loose.

---

## [v2.1] — 2026-06-01 (Ready-to-Deploy)

> Karen 100% lista. Clone + install.sh → ordenador nuevo operativo turno 1.

### Added — Instalador inteligente
- `scripts/install.sh` v2 — 9 fases: estructura + memoria + ~/.claude config + pre-reqs + auto-install brew (mac) + Docker stack opcional + verify final.
- `scripts/verify-install.sh` — validación post-install (50+ checks: estructura, dominios, hooks, subagents, MCPs, Docker, gitignore).

### Added — Hooks bash ejecutables reales (6)
- `load-rules.sh` (SessionStart) — inyecta rules-learned + profile al boot.
- `capture-correction.sh` (UserPromptSubmit) — detecta correcciones Nico, append a rules-learned.
- `domain-firewall.sh` (PreToolUse) — bloquea cross-domain según reglas YAML por subagent.
- `raiz-limpia-guard.sh` (PreToolUse Write) — bloquea archivos sueltos raíz proyecto.
- `secrets-guard.sh` (PreToolUse Write) — bloquea escritura secrets fuera .env (patrones AWS/Anthropic/OpenAI/GitHub/Slack/Google/private keys).
- `cliender-isolation-guard.sh` (UserPromptSubmit) — alerta menciones Cliender en cuenta personal.

### Added — Subagents config JSON (6)
- `karen-orchestrator.json` (T1) — distribuidor, sin acceso dominios directos.
- `karen-dev.json` (T1) — RW dev paths, GitHub MCP, full Bash dev.
- `karen-finance.json` (T2 SENSITIVE) — sparring socrático obligatorio, citation required, 4 preguntas pre-research.
- `karen-health.json` (T2 SENSITIVE) — disclaimer no-médico, stop triggers diagnóstico/medicación.
- `karen-research.json` (T1) — research multi-fuente verificada, citation verbatim.
- `karen-learn.json` (T1) — Feynman + spaced repetition + active recall.

### Added — Firewall rules txt (6)
- Por subagent: `~/.claude/karen/firewall/<subagent>.txt` con DENY/ALLOW paths.
- Aplicado por hook `domain-firewall.sh` automático.

### Added — Memory stack Docker
- `templates/docker-compose.memory.yml` — Mem0 (8888) + Neo4j (7474/7687) listos.
- Inline FastAPI Mem0 server (add/search/health endpoints).
- Healthchecks + auto-restart.
- Network localhost-only.

### Added — Config templates
- `templates/.claude/karen/profile.json` — hot facts completos.
- `templates/.env.example` — placeholders Anthropic, Neo4j, GitHub PAT, OAuth.
- `templates/.claude/settings.json` v2 — hooks Karen wired, plugins, permissions.

### Added — Guías
- `docs/FIRST-RUN.md` — protocolo exacto Karen turno 1 con ejemplo transcript completo.
- `.gitattributes` — preserva permisos executable + LF line endings.

### Changed
- `scripts/install.sh` re-escrito completo (16KB, 9 fases).
- `README.md` quickstart 60s.

### Privacy
- Cero datos personales en repo público.
- Templates con placeholders.
- `.gitignore` exhaustivo.

---

## [v2.0-spec] — 2026-06-01 (Neural Backbone — SPEC)

> Research SOTA personal AI assistants 2026 aplicado. Specs implementación listos. Pendiente código wrappers MCP + hooks.

### Added — Arquitectura neuronal completa
- `docs/03-arquitectura/NEURAL-ARCHITECTURE.md` — 7 capas (Constitution → Continuous Loop) inspirado en harness engineering 2026.
- `docs/03-arquitectura/MEMORY-STACK.md` — Mem0 + Graphiti + LightRAG híbrido. Hot facts JSON + semantic vector + knowledge graph temporal.
- `docs/03-arquitectura/TIERS-AND-FIREWALL.md` — 5 tiers (T0-T4) + domain firewall por subagent + trust score 0-1000.

### Added — Personalidad y anti-patterns
- `docs/02-personalidad-karen/ANTI-PATTERNS.md` — 16 anti-patterns documentados con mitigación (sycophancy, hallucinations, authority transfer, etc.).

### Added — Workflows v2
- `docs/05-workflow/RULE-BOOK-AUTO.md` — Self-updating rule book. Hook capture-correction.sh + load-rules.sh.
- `docs/05-workflow/UPGRADES.md` — Roadmap v1→v3 con tasks priorizadas.

### Added — Commands nuevos
- `commands/morning-brief.md` — Fan-out paralelo subagents. Digest único.
- `commands/karen-learn-me.md` — Active learning onboarding (max 5 preguntas alta entropía).
- `commands/karen-grant.md` — Permisos temporales (network, write, tier-up, cross-domain).
- `commands/karen-audit.md` — Audit semanal: trust scores, violations, grants, sycophancy.

### Added — Seed rules
- `templates/.claude/karen/rules-learned-seed.md` — 15 reglas seed pre-cargadas (severity high/med).

### Research aplicado
- Mem0 dual-store (vector + grafo) — Mem0 2026 algorithm.
- Graphiti bi-temporal edges (`valid_from`/`valid_to`).
- LightRAG 65-80% token savings vs Microsoft GraphRAG.
- Harness Engineering pattern: "harness is the moat, not prompt".
- Microsoft Agent Governance Toolkit (Apr 2026): trust scoring 0-1000.
- Pipelock capability separation.
- Active Learning cold-start (arXiv 2309.00356).
- Anti-sycophancy after GPT-4o "glazing" incident Apr 2025.
- Citation-required mode contra personal data hallucinations.

---

## [v1.0] — 2026-06-01 (Foundation)

### Added — Repositorio inicial
- `CLAUDE.md` autoinstalable.
- `_ATAJOS.md`, `README.md`, `.gitignore` exhaustivo (cero datos sensibles públicos).

### Added — Documentación core
- `docs/01-quien-soy/PERFIL_NICO.md` — perfil Nico (nombre = "Nico", completo solo en memoria local).
- `docs/02-personalidad-karen/IDENTIDAD.md` — Jarvis + Friday, modo decisión por dominio.
- `docs/03-arquitectura/ESTRUCTURA.md` — carpetas dominios.
- `docs/03-arquitectura/MEMORIA.md` — sistema memoria v1.
- `docs/04-skills-catalogo/SKILLS.md` — catálogo skills + plugins + MCPs.
- `docs/05-workflow/WORKFLOWS.md` — flujos típicos por dominio.
- `docs/05-workflow/REGLAS.md` — reglas operativas.

### Added — Scripts + templates
- `scripts/install.sh` — auto-instalación ordenador nuevo.
- `templates/.claude/settings.json` — config Claude Code default.
- `templates/.claude/.mcp.json` — MCP servers core.
- `templates/.claude/settings.local.json.example` — privado por máquina.
- `templates/karen-personal-root/02-DEV/stack-personal.md` — stack Nico Next.js + Python + Docker.

### Added — Agents (5)
- `agents/architect.md` — Senior arquitectura.
- `agents/code-reviewer.md` — Review código con severidades.
- `agents/finanzas-sparring.md` — Sparring socrático financiero.
- `agents/salud-coach.md` — Coach salud con disclaimer médico.
- `agents/learn-tutor.md` — Tutor aprendizaje Feynman + spaced rep.

### Added — Commands (6)
- `commands/sparring.md`, `commands/dominio.md`, `commands/agenda.md`, `commands/memoria-add.md`, `commands/portafolio.md`, `commands/research.md`.

### Privacy
- Rebrand titulo "KAREN AI P.A". Nombre real removido de docs públicos.
- `.gitignore` con 8 dominios + secrets + claude config local.

---

## Convenciones versionado

- **v1.x** — Foundation, markdown-only memoria.
- **v2.x** — Neural backbone: Mem0 + Graphiti + tiers + firewall + auto rule book.
- **v3.x** — Experimental: capability separation, multi-perspective council, harness-evolver.
- **v4.x** — Speculative: multi-modal, predictive, federated.

### Tags git
- `v1.0` — initial release ✅
- `v2.0-spec` — specs documentación, sin código wrappers ⬅ ACTUAL
- `v2.0` — código MCP wrappers + hooks implementados (target Julio 2026)
- `v2.5` — active learning + audit weekly (target Agosto 2026)
- `v3.0-experimental` — capability separation harness (target Q4 2026)
