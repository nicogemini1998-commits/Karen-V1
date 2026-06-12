# SKILLS — Catálogo completo Karen Personal

> Skills, plugins y MCPs que Nico usa y deben estar en Karen Personal.

---

## 📦 Plugins a instalar (Claude Code marketplace)

Estos plugins traen muchas skills + MCPs preconfigurados.

### Esenciales
| Plugin | Para qué |
|---|---|
| `caveman@caveman` | Modo eficiencia tokens (`/caveman`) |
| `claude-mem@thedotmack` | Memoria persistente cross-sesión + `mem-search` |
| `everything-claude-code@everything-claude-code` | Mega-suite dev (review, build-fix, e2e, patterns por lenguaje) |
| `firecrawl@claude-plugins-official` | Web scraping + search rico |
| `brightdata-plugin@claude-plugins-official` | Proxy + scraper avanzado |
| `bigdata-com@claude-plugins-official` | **Research financiero** (crítico finanzas) |

### Opcionales según uso
| Plugin | Para qué |
|---|---|
| `circleback@claude-plugins-official` | Notas reuniones (útil personal) |
| `aws-amplify@claude-plugins-official` | Side projects cloud AWS |
| `box@claude-plugins-official` | File management |
| `atlassian@claude-plugins-official` | Si Nico usa Jira/Confluence personal |
| `asana@claude-plugins-official` | Si Nico usa Asana personal |

### NO portar (relacionado con trabajo Cliender)
- `zoominfo` (B2B sales — solo empresa)
- `lusha` MCP (sales intelligence — solo empresa)
- `cds-mcp` (SAP CAP)

---

## 🎯 TIER 1 — Skills uso constante

### Memoria + búsqueda
| Skill | Función |
|---|---|
| `graphify` | Knowledge graph desde input. **CRÍTICO** — solo cuando esté instalada como skill local (`~/.claude/skills/graphify/`). No viene con este repo; si falta, Karen usa memoria markdown v1 y lo reporta. |
| `claude-mem:mem-search` | Búsqueda memoria histórica |
| `claude-mem:knowledge-agent` | Agente conocimiento |
| `claude-mem:smart-search` | Búsqueda inteligente |
| `claude-mem:smart-outline` | Outline automático |
| `claude-mem:timeline-report` | Reportes timeline |
| `claude-mem:make-plan` | Planning con memoria |

### File ops (sustituye Read/Edit/Grep/Glob)
| Tool | Función |
|---|---|
| `mcp__hex-line__read_file` | Read con hash verification |
| `mcp__hex-line__edit_file` | Edit con anchor checksums |
| `mcp__hex-line__grep_search` | Grep edit-ready |
| `mcp__hex-line__inspect_path` | Tree + pattern search |
| `mcp__hex-line__outline` | Outline estructural |
| `mcp__hex-line__bulk_replace` | Multi-file refactor |
| `mcp__hex-line__write_file` | Write sin pre-read |
| `mcp__hex-line__changes` | Diff semántico |
| `mcp__hex-line__verify` | Verificar checksums |

### Research
| Skill | Función |
|---|---|
| `deep-research` | Multi-fuente + verificación adversarial |
| `firecrawl:firecrawl-search` | Search web rico |
| `firecrawl:firecrawl-scrape` | Scrape páginas |
| `firecrawl:firecrawl-crawl` | Crawl sitios completos |
| `firecrawl:firecrawl-map` | Mapear estructura sitio |
| `firecrawl:firecrawl-agent` | Agente firecrawl autónomo |

### Workflow base
| Skill | Función |
|---|---|
| `plan` | Planning estructurado |
| `verify` | Verificar cambios en runtime |
| `run` | Lanzar app y ver |
| `handoff` | Pasar contexto entre sesiones |
| `code-review` | Review código (low/med/high effort) |
| `simplify` | Aplicar fixes de code-review |
| `find-skills` | Buscar skill correcta |
| `env-check` | Verificar entorno |

### Commands custom Karen (vienen con el repo, `commands/`)
| Command | Función |
|---|---|
| `/morning-brief` | Digest mañanero fan-out subagents |
| `/evening-wind-down` | Cierre de día (nuevo v1.1) |
| `/deep-reflection` | Reflexión profunda periódica (nuevo v1.1) |
| `/karen-backup` | Backup memoria + config (nuevo v1.1) |
| `/karen-audit-trail` | Consulta del audit trail append-only (nuevo v1.1) |
| `/karen-learn-me` | Onboarding active learning (5 preguntas máx) |
| `/karen-audit` | Auditoría: rules, violations, grants |
| `/karen-grant` | Permisos temporales (network, write, tier-up) |
| `/karen-cheap-mode` | Routing Haiku + caching agresivo |
| `/karen-redteam` | Red-team rápido (IPI/jailbreak/memory poisoning) |
| `/verify-integrity` | Verifica integrity ledger + MCP pins |
| `/sparring` `/dominio` `/agenda` `/memoria-add` `/portafolio` `/research` | Operativa por dominio |

---

## 🎨 TIER 1 DISEÑO — Las que Nico usa fuerte

### Core diseño frontend
| Skill | Función |
|---|---|
| `frontend-design` | Crear interfaces production-grade distintivas |
| `design-taste-frontend` | Senior UI/UX engineer, anti-template |
| `design-system` | Sistemas diseño completos |
| `impeccable` | Audit/polish/redesign UI completa |
| `frontend-patterns` | Patrones reutilizables |
| `ui-demo` | Grabación demos UI con Playwright |
| `prototype` | Prototipado rápido |
| `dashboard-builder` | Dashboards monitoring funcionales |
| `web-artifacts-builder` | Artefactos web standalone |

### Estilos visuales
| Skill | Función |
|---|---|
| `high-end-visual-design` | Diseño nivel agencia premium |
| `liquid-glass-design` | iOS 26 Liquid Glass (glassmorphism real) |
| `industrial-brutalist-ui` | Neo-brutalism |
| `minimalist-ui` | Minimalismo disciplinado |
| `canvas-design` | Diseño en canvas (Pencil.dev) |

### Taste / criterio
| Skill | Función |
|---|---|
| `gpt-taste` | GPT taste styling |
| `stitch-design-taste` | Stitching design references |
| `theme-factory` | 10 themes pre-set + custom on-the-fly |
| `brandkit` | Kit marca |
| `brand-guidelines` | Guías marca |

### Imagen + código
| Skill | Función |
|---|---|
| `image-to-code` | Convertir imagen → código frontend |
| `imagegen-frontend-web` | Generar imágenes web premium |
| `imagegen-frontend-mobile` | Imágenes mobile |
| `algorithmic-art` | Arte generativo p5.js |
| `slack-gif-creator` | GIFs Slack |
| `ui-ux-pro-max-skill` | UI/UX 161 reasoning rules + 67 styles |

### Refactor diseño
| Skill | Función |
|---|---|
| `redesign-existing-projects` | Rediseñar proyecto existente |
| `improve-codebase-architecture` | Mejorar arquitectura |

### Animación + video
| Skill | Función |
|---|---|
| `everything-claude-code:manim-video` | Videos Manim |
| `everything-claude-code:remotion-video-creation` | Videos Remotion |
| `remotion-best-practices` | Best practices Remotion |
| `everything-claude-code:video-editing` | Edición video |
| `everything-claude-code:fal-ai-media` | Generación media Fal.ai |

---

## 📝 TIER 2 — Copywriting + Marketing

### Copy
| Skill | Función |
|---|---|
| `copywriting` | Copy páginas (home, landing, pricing) |
| `copy-editing` | Editar copy existente |
| `cold-email` | B2B cold outreach |
| `email-sequence` | Lifecycle email |
| `social-content` | Social media (LinkedIn, Twitter, IG, TikTok) |
| `humanize` / `humanizer` | Hacer texto IA sonar humano |
| `readability` | Mejorar legibilidad |
| `detect-ai` | Detectar texto IA (0-100 score) |

### Marketing strategy
| Skill | Función |
|---|---|
| `marketing-psychology` | Mental models, sesgos |
| `marketing-ideas` | Ideas post-launch |
| `paid-ads` | Ads pagados |
| `ad-creative` | Creatividad ads |
| `launch-strategy` | Plan launch productos |
| `customer-research` | Research clientes |
| `competitor-alternatives` | Páginas competitor/alternative |
| `lead-magnets` | Lead magnets |
| `pricing-strategy` | Pricing |
| `content-strategy` | Estrategia contenido |

### CRO (Conversion Rate Optimization)
| Skill | Función |
|---|---|
| `page-cro` | CRO páginas |
| `form-cro` | CRO forms |
| `popup-cro` | CRO popups |
| `onboarding-cro` | CRO onboarding |
| `signup-flow-cro` | CRO signup |
| `paywall-upgrade-cro` | CRO paywall |
| `churn-prevention` | Prevención churn |
| `ab-test-setup` | A/B testing |

### SEO
| Skill | Función |
|---|---|
| `seo-audit` | Auditoría SEO |
| `ai-seo` | SEO para AI search |
| `programmatic-seo` | SEO programático escala |
| `schema-markup` | Structured data |
| `site-architecture` | Arquitectura sitio |
| `analytics-tracking` | Tracking analytics |

---

## 💻 TIER 2 — Development

### Generales
| Skill | Función |
|---|---|
| `claude-api` | Apps con Claude API (caching, thinking) |
| `mcp-server-patterns` | Construir MCP servers |
| `api-design` | Diseño APIs |
| `api-connector-builder` | Conectores API |
| `mcp-builder` | Build MCP servers |
| `backend-patterns` | Patrones backend |
| `agentic-engineering` | Patterns agentes IA |
| `tdd` | TDD |
| `webapp-testing` | Testing web apps |
| `diagnose` | Diagnosticar problemas |
| `prompt-master` | Optimizar prompts cualquier tool IA |
| `continuous-agent-loop` | Loops agentes autónomos |

### Por lenguaje (everything-claude-code)
Para cada lenguaje: `*-patterns`, `*-testing`, `*-review`, `*-build-resolver`:
- typescript / javascript
- python
- rust
- go
- java / spring-boot
- kotlin (Android, KMP, Ktor)
- csharp / dotnet
- cpp
- perl
- dart / flutter
- swift (concurrency, actor-persistence, foundation-models)

---

## 💰 TIER 2 — Finanzas (BigData.com)

Skills financieros premium. Foco fuerte para sparring inversiones Nico.

| Skill | Función |
|---|---|
| `bigdata-com:quick-take` | Análisis rápido empresa/sector |
| `bigdata-com:valuation-snapshot` | Valoración rápida |
| `bigdata-com:sector-analysis` | Análisis sector completo |
| `bigdata-com:peer-comparables` | Comparables peers |
| `bigdata-com:scenario-analysis` | Escenarios bull/base/bear |
| `bigdata-com:financial-research-analyst` | Research analyst completo |
| `bigdata-com:earnings-preview` | Preview earnings próximo |
| `bigdata-com:earnings-reaction` | Análisis post-earnings |
| `bigdata-com:earnings-quality-screen` | Screening calidad earnings |
| `bigdata-com:earnings-digest` | Resumen earnings season |
| `bigdata-com:catalyst-monitor` | Monitor catalysts |
| `bigdata-com:investment-memo` | Memo inversión |
| `bigdata-com:moat-governance-review` | Moat + governance |
| `bigdata-com:regional-comparison` | Comparativa regional |
| `bigdata-com:country-analysis` | Análisis país |
| `bigdata-com:country-sector-analysis` | País × sector |
| `bigdata-com:variant-perception` | Perspectivas alternativas |
| `bigdata-com:thematic-research` | Research temático |
| `bigdata-com:risk-assessment` | Evaluación riesgo |
| `bigdata-com:sector-playbook` | Playbook sector |
| `bigdata-com:g7-comparison` | Comparación G7 |
| `bigdata-com:cross-sector` | Análisis cross-sector |
| `bigdata-com:company-brief` | Brief compañía |

---

## 📚 TIER 2 — Productividad + Docs

| Skill | Función |
|---|---|
| `doc-coauthoring` | Co-autoría docs estructurados |
| `handoff` | Handoff entre agentes/sesiones |
| `studio-resume` | Resume/portafolio |
| `follow-up` | Follow-ups |
| `grill-me` / `grill-with-docs` | Auto-cuestionar con docs |
| `word-stats` | Stats texto |
| `pdf` | Trabajar con PDFs |
| `docx` | Word docs |
| `pptx` | PowerPoint |
| `xlsx` | Excel |
| `markitdown` | Markdown ops |
| `theme-factory` | Estilizar artefactos |

---

## 🎬 TIER 3 — Situacional

| Skill | Función |
|---|---|
| `caveman:caveman` | Modo eficiencia tokens (lite/full/ultra) |
| `caveman:compress` | Comprimir output |
| `caveman:caveman-commit` | Commits caveman style |
| `claude-mem:do` | Ejecutar con memoria |
| `firecrawl:skill-gen` | Generar skills firecrawl |
| `brightdata-plugin:design-mirror` | Espejar diseño otro sitio |
| `brightdata-plugin:competitive-intel` | Inteligencia competitiva |
| `brightdata-plugin:scraper-builder` | Construir scraper |

---

## 🔌 MCP Servers — instalación

### Vienen con plugins
- `mcp__hex-line__*` (output style hex-line)
- `mcp__firecrawl__*` (plugin firecrawl)
- `mcp__brightdata__*` (plugin brightdata)
- `mcp__bigdata-com__*` (plugin bigdata-com)
- `mcp__circleback__*` (plugin circleback)

### Instalar manual (`~/.claude/.mcp.json`)
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem",
               "/Users/<USER>/karen-personal"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

### Autenticar (OAuth, no en repo)
- `gmail` (cuenta personal)
- `google-calendar` (cuenta personal)
- `google-drive` (cuenta personal)
- `microsoft-365` / `outlook` (cuenta empresa READ-ONLY)
- `github` (token personal, scope `repo` + `read:user`)

---

## 🎯 Skills prioritarias por dominio

| Dominio | Skill principal | Apoyo |
|---|---|---|
| **Dev** | `hex-line`, `plan`, `code-review`, `verify` | `claude-api`, `tdd`, `e2e`, `build-fix` |
| **Diseño UI** | `frontend-design`, `design-taste-frontend`, `impeccable` | `theme-factory`, `liquid-glass-design`, `high-end-visual-design` |
| **Finanzas** | `bigdata-com:*`, `deep-research` | `firecrawl-search`, sparring socrático |
| **Salud** | `deep-research`, `memory` | (skill-specific limitada — más conversacional) |
| **Productividad** | Gmail/Calendar/Notion MCPs | `doc-coauthoring`, `follow-up` |
| **Aprendizaje** | `deep-research`, `doc-coauthoring` | `grill-me`, `grill-with-docs` |
| **Relaciones (drafts)** | (output puro, sin skill específico) | `humanize`, `copy-editing` |
| **Compras** | `deep-research`, `firecrawl-search` | `brightdata:competitive-intel` |

---

## 📋 Checklist instalación skills

Karen ejecuta en onboarding:

```
1. /plugin marketplace  → instalar plugins esenciales
2. Verificar /find-skills lista tier 1
3. Configurar ~/.claude/.mcp.json con servers manuales
4. Auth OAuth Gmail/Calendar/Outlook
5. /graphify init namespaces por dominio (solo si la skill graphify está instalada — si no, skip y anotar)
6. Test cada skill tier 1 con dummy query
7. Reportar a Nico: instaladas ✓ / faltan ✗
```
