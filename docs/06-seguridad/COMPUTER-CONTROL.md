# COMPUTER CONTROL — Karen controla ordenador

> Cómo Karen accede + controla ordenador + navegador + sistema con SEGURIDAD máxima.

---

## Capacidades disponibles 2026

### 1. Computer Use API (Anthropic)
- Karen ve screenshots + mueve mouse + tipea + ejecuta clicks.
- Solo Claude 4+ (Opus/Sonnet).
- Disponible vía SDK / API directamente.
- **Tiers:** SANDBOXED only (T0-T1 con guards).

### 2. Playwright (browser)
- Automatización browsers (Chrome, Firefox, Safari, Edge).
- Karen Cliender ya usa intensamente.
- Mejor opción default para tareas web.

### 3. Bash + filesystem (ya tiene)
- Karen ya ejecuta comandos shell con allowlist.
- Hooks Karen ya filtran destructivos.

### 4. AppleScript (Mac)
- Karen puede automatizar Mail.app, Calendar, Finder, etc. en macOS.
- Vía Bash `osascript`.

### 5. Power Automate / AppleScript Editor / Shortcuts iOS
- Triggers complejos.

---

## ⚠️ Riesgo: 3-of-3 Rule of Two violation

Computer use + browser + filesystem write = **agente con TODOS los properties**:
- ✅ Untrusted input (web, screenshots con texto)
- ✅ Sensitive read (puede ver pantalla completa, otras apps)
- ✅ External write (clicks, navegación, archivos)

**Esto es indefensable sin human-in-the-loop en cada acción consequential.**

### Mitigación obligatoria

1. **Sandbox** — VM o container dedicado, NO ordenador principal Nico.
2. **Allowlist apps** — Karen solo controla apps específicas (Chrome, terminal específico).
3. **Network=none** opcional para sandbox.
4. **Confirm humano** antes acciones destructivas (delete, install, send).
5. **Audit log frame-by-frame** screenshots + acciones.
6. **Subagent dedicado tier T4** (privileged, one-shot, confirm cada step).

---

## Arquitectura recomendada Karen

```
┌────────────────────────────────────────────────────────────┐
│ ORDENADOR PRINCIPAL Nico                                   │
│                                                            │
│  Claude Code Desktop                                       │
│  (Karen orchestrator + dev + finance + ...)                │
│                                                            │
│         ↓ delega tarea browser/computer                    │
│         ↓                                                  │
└─────────┼──────────────────────────────────────────────────┘
          │
          ↓ (Docker / VM aislada)
┌─────────┴──────────────────────────────────────────────────┐
│ SANDBOX (Docker container o VM)                            │
│                                                            │
│  karen-computer-use (T4 privileged, one-shot)              │
│    - Playwright Chrome headless                            │
│    - Computer Use API screenshots                          │
│    - Bash limitado                                         │
│    - Network: allowlist específico tarea                   │
│    - Filesystem: solo /tmp/karen-tasks/                    │
│                                                            │
│  Confirm Nico ANTES cada acción destructiva.               │
│  Audit log: screenshots + clicks + outputs.                │
└────────────────────────────────────────────────────────────┘
```

---

## Tier de uso por capacidad

| Capacidad | Tier | Use case típico |
|---|---|---|
| Bash allowlist | T1 | npm, git, docker, ls — ya activo |
| File ops `hex-line` | T1 | Read/Edit/Write project files |
| Playwright headless | T2 | Form fill (login, scrape específico) |
| Playwright visible | T3 | Demos UI, screenshots para Nico |
| Computer Use API (mouse + screenshot) | T3 | Tareas GUI complejas (apps sin API) |
| AppleScript Mac | T3 | Mail.app, Calendar.app, Finder ops |
| Shortcuts iOS via API | T2 | Triggers móvil → Karen Desktop |
| Bash sin allowlist | T4 | Solo casos excepcionales, confirm cada call |

---

## Setup Playwright (ya disponible)

```bash
# Ya viene con plugin everything-claude-code MCP
# Skill ui-demo usa Playwright para grabar demos
# Skill webapp-testing usa para e2e
```

### Uso ejemplo

```
/run-playwright "abrir trade-republic.com login con env TOKEN"
```

Karen ejecuta sandbox Playwright + confirm Nico antes acciones.

### Reglas Playwright Karen

- **Default headless** (`headless: true`).
- **Headful solo si Nico pide ver** (demos, debug visual).
- **Network allowlist** per script.
- **Screenshots autosave** `~/karen-personal/05-PRODUCTIVIDAD/playwright-runs/AAAA-MM-DD/`.
- **NO usar para acciones destructivas** sin confirm.

---

## Setup Computer Use API (Anthropic)

### Habilitar

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-...
COMPUTER_USE_ENABLED=true
```

### Sandbox Docker

```yaml
# templates/docker-compose.computer-use.yml
services:
  karen-computer:
    image: anthropic/claude-computer-use:latest
    container_name: karen-computer
    ports:
      - "127.0.0.1:8501:8501"
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - DISPLAY=:0
    volumes:
      - ./computer-use-data:/tmp/karen-tasks
    network_mode: bridge  # NO network=host
```

### Acceso

Subagent `karen-computer-use` (T3 default, T4 confirm-each-action mode):
- Karen genera comandos.
- Sandbox ejecuta.
- Screenshot post-acción.
- Si destructive → confirm humano.

### Audit

Cada acción computer-use → log:
```jsonl
{"ts":"...","action":"click","target":"button:Submit","screenshot_before":"...","screenshot_after":"...","confirmed_by":"nico"}
```

---

## Setup AppleScript (macOS)

```bash
# Karen ejecuta vía Bash allowlist:
osascript -e 'tell application "Mail" to get unread count of inbox'
```

### Allowlist apps macOS

| App | Acciones permitidas | Tier |
|---|---|---|
| Mail.app | read counts, read subjects | T1 |
| Mail.app | send email | T3 (confirm) |
| Calendar.app | read events | T1 |
| Calendar.app | create event | T2 (confirm) |
| Finder | navigate, list | T1 |
| Finder | delete | T3 (confirm) |
| Terminal | (Karen ya usa Bash directo) | n/a |
| Safari/Chrome | (use Playwright en su lugar) | n/a |

### NO permitido AppleScript

- System Preferences cambios.
- Disk utility.
- Apps de terceros sin allowlist explícito.
- `do shell script with administrator privileges` — NUNCA.

---

## Setup Shortcuts iOS (trigger remoto)

### Patrón

iPhone Nico → Shortcut "Karen Ask" → HTTP POST a Karen webhook → Karen procesa.

### Setup

1. Cloudflare Tunnel (gratis) abre puerto local Karen → URL pública.
2. iOS Shortcuts hace POST con prompt.
3. Karen ejecuta + responde vía notification iOS.

### Seguridad

- **HMAC signing** request (no token JWT que pueda leak).
- **Allowlist comandos** desde Shortcuts (no full Bash).
- **Rate limit** 10 req/min.
- **Audit log** `~/.claude/karen/shortcuts-ios.jsonl`.

---

## Reglas universales computer control

### Inviolables

1. **NUNCA sudo / admin** sin Nico confirmando per-comando.
2. **NUNCA `rm -rf` HOME o /** — hook bloquea preventivo.
3. **NUNCA modificar System apps** macOS.
4. **NUNCA acciones destructivas en producción** (deploy, drop DB, force push) sin confirm.
5. **AUDIT LOG todo** — screenshots + acciones + timestamps.
6. **Confirm humano** before:
   - Send email
   - Create calendar event externo (con invitees)
   - Push to GitHub
   - Deploy
   - Modify settings sistema
   - Install software
   - Buy/transact algo

### Default behavior

- **Headless > visible** salvo Nico pida.
- **Read > write** salvo task lo requiera.
- **Sandbox > host** computer use API.
- **Allowlist > denylist**.

---

## Workflow ejemplo — Karen agenda reunión

```
Nico: "agenda reunión con Pedro el martes 11am"

Karen orchestrator:
  → karen-orchestrator identifica dominio: productividad
  → delega a sub-task agenda

Sub-task:
  1. Query Gmail/Calendar personal: ¿Quién es Pedro?
     - Mem0 lookup → "Pedro Martínez, contacto desde 2025-11"
  2. Verifica disponibilidad Nico martes 11am (Calendar read).
  3. ⚠ CONFIRM antes crear evento:
     "Voy a crear: 'Reunión Pedro Martínez · martes 2026-06-17 11:00 · 1h'.
      ¿Email a pedro@example.com? ¿Confirmas?"
  4. Si Nico confirma → AppleScript Calendar.app create event + Mail.app send invite.
  5. Audit log: action + recipient + timestamp.

Output Karen:
  ✓ Evento creado en Calendar personal.
  ✓ Email invite enviado a pedro@example.com.
  Audit: ~/.claude/karen/actions/2026-06-15T15-22_calendar-create.json
```

---

## Bibliografía

- [Anthropic — Computer Use API docs](https://docs.anthropic.com/en/docs/build-with-claude/computer-use)
- [Anthropic — Claude Computer Use Demo (Docker)](https://github.com/anthropics/anthropic-quickstarts/tree/main/computer-use-demo)
- [Playwright docs](https://playwright.dev/)
- [Microsoft Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [Apple — AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/)
- [iOS Shortcuts + HTTP](https://support.apple.com/guide/shortcuts/get-contents-of-url-apdcbf0fbf28/ios)
