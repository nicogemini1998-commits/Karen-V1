# _ATAJOS — Karen Personal

> Hub rutas rápidas. NO contiene información. Solo punteros.

## Estructura raíz

| Path | Para qué |
|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | Identidad Karen + onboarding |
| [`README.md`](./README.md) | Overview repo + instalación |
| [`docs/`](./docs/) | Documentación completa |
| [`templates/`](./templates/) | Plantillas listas (settings.json, hooks, carpetas) |
| [`scripts/install.sh`](./scripts/install.sh) | Auto-instalación |
| [`agents/`](./agents/) | Agentes Claude custom |
| [`commands/`](./commands/) | Slash commands custom |

## Docs

| # | Doc | Tema |
|---|---|---|
| 01 | [`docs/01-quien-soy/PERFIL_NICO.md`](./docs/01-quien-soy/PERFIL_NICO.md) | Quién es Nico |
| 02 | [`docs/02-personalidad-karen/IDENTIDAD.md`](./docs/02-personalidad-karen/IDENTIDAD.md) | Personalidad Karen |
| 02 | [`docs/02-personalidad-karen/ANTI-PATTERNS.md`](./docs/02-personalidad-karen/ANTI-PATTERNS.md) | 16 anti-patterns NUNCA hacer |
| 03 | [`docs/03-arquitectura/NEURAL-ARCHITECTURE.md`](./docs/03-arquitectura/NEURAL-ARCHITECTURE.md) | Red neuronal 7 capas |
| 03 | [`docs/03-arquitectura/MEMORY-STACK.md`](./docs/03-arquitectura/MEMORY-STACK.md) | Mem0 + Graphiti + LightRAG |
| 03 | [`docs/03-arquitectura/TIERS-AND-FIREWALL.md`](./docs/03-arquitectura/TIERS-AND-FIREWALL.md) | Tiers T0-T4 + firewall |
| 03 | [`docs/03-arquitectura/ESTRUCTURA.md`](./docs/03-arquitectura/ESTRUCTURA.md) | Carpetas, dominios |
| 03 | [`docs/03-arquitectura/MEMORIA.md`](./docs/03-arquitectura/MEMORIA.md) | Sistema memoria v1 (markdown) |
| 04 | [`docs/04-skills-catalogo/SKILLS.md`](./docs/04-skills-catalogo/SKILLS.md) | Catálogo skills + MCPs |
| 05 | [`docs/05-workflow/RULE-BOOK-AUTO.md`](./docs/05-workflow/RULE-BOOK-AUTO.md) | Self-updating rule book |
| 05 | [`docs/05-workflow/WORKFLOWS.md`](./docs/05-workflow/WORKFLOWS.md) | Flujos típicos |
| 05 | [`docs/05-workflow/REGLAS.md`](./docs/05-workflow/REGLAS.md) | Reglas operativas |
| 05 | [`docs/05-workflow/UPGRADES.md`](./docs/05-workflow/UPGRADES.md) | Roadmap v1→v3 |
| 99 | [`docs/99-showcase/`](./docs/99-showcase/) | HTML demos: showcase premium + versión para niños |

## Dominios (creados por install.sh)

| # | Dominio | Para qué |
|---|---|---|
| 01 | `01-MEMORIA/` | Memoria persistente por dominio (gitignored) |
| 02 | `02-DEV/` | Side projects código |
| 03 | `03-FINANZAS/` | Inversiones, fiscalidad ES (gitignored) |
| 04 | `04-SALUD-FITNESS/` | Rutinas, nutrición, tracking (gitignored) |
| 05 | `05-PRODUCTIVIDAD/` | GTD, Notion sync, calendarios |
| 06 | `06-APRENDIZAJE/` | Libros, cursos, idiomas |
| 07 | `07-RELACIONES/` | Drafts mensajes (gitignored) |
| 08 | `08-HOBBIES/` | Hobbies |
| 09 | `09-COMPRAS-RESEARCH/` | Decisiones compra grandes |
| 10 | `10-GRAPHIFY/` | Knowledge graph (gitignored) |

## Comandos rápidos Claude Code

- `/plan` — planning estructurado
- `/verify` — verificar cambios runtime
- `/run` — lanzar app
- `/code-review` — revisar diff
- `/simplify` — aplicar fixes
- `/build-fix` — resolver build roto
- `/deep-research <tema>` — research multi-fuente
- `/mem-search <query>` — buscar memoria
- `/graphify` — knowledge graph
- `/caveman` — modo eficiencia tokens
- `/handoff` — pasar contexto entre sesiones
- `/sparring <tema>` — modo sparring socrático forzado (custom)

## Por dominio — skill principal

| Dominio | Skill |
|---|---|
| Dev | hex-line + plan + code-review + verify |
| Finanzas | bigdata-com:* + deep-research |
| Salud | deep-research + memory |
| Productividad | Notion MCP + Gmail/Outlook MCP |
| Aprendizaje | deep-research + doc-coauthoring |
| Compras | deep-research + firecrawl |
