---
description: Consulta del audit-log.jsonl — qué tools usó Karen y cuándo. Filtros por fecha/tool, resumen de uso y anomalías de horario.
---

# /karen-audit-trail

Consulta forense del trail de tool calls. Fuente: `~/.claude/karen/audit-log.jsonl` — lo escribe el hook `audit-trail.sh` (PreToolUse `*`, 1 línea JSONL por CADA tool call, nunca bloquea).

## Qué hay en cada línea (y qué NO)

```json
{"ts": "2026-06-15T14:32:01Z", "tool": "Bash", "args_hash": "a1b2c3d4e5f60718", "session_id": "abc123"}
```

- `ts` ISO8601 UTC, `tool`, `args_hash` (sha256, primeros 16 chars), `session_id` si existe.
- **Los argumentos NUNCA están en claro** — solo el hash. El trail responde *qué tool y cuándo*, no *con qué contenido*. Eso es by design (el log no puede filtrar secretos). Sí permite detectar repeticiones: mismo `args_hash` = misma llamada exacta.

## Sintaxis

```
/karen-audit-trail                      # resumen últimos 7 días
/karen-audit-trail --date 2026-06-15    # solo ese día
/karen-audit-trail --tool Bash          # solo ese tool
/karen-audit-trail --export json        # dump filtrado a 01-MEMORIA/audit/
```

Flags combinables: `--date 2026-06-15 --tool Bash --export json`.

## Comportamiento

1. Lee `audit-log.jsonl` con `jq`, aplica filtros.
2. Calcula resumen: tools más usados, calls por día, sesiones.
3. Detecta anomalías y las marca.

## Output

```
🔎 KAREN AUDIT TRAIL — últimos 7d

TOOLS MÁS USADOS
─────────────
Read       412  ████████████
Bash       188  ██████
Task        64  ██
Write       41  █
mcp gmail   12  ▌

Calls totales: 717 · Sesiones: 9 · Días activos: 6/7

ANOMALÍAS
─────────────
⚠ 2026-06-14 03:12Z — 14 calls Bash fuera de horario habitual (baseline: 07-23h local)
⚠ args_hash f00dbabe... repetido 23x en 5min (¿loop?)
✓ Sin tools nunca-vistos esta semana

EXPORT
─────────────
(con --export json) → 01-MEMORIA/audit/2026-06-15_trail.json
```

## Definición de anomalía (concreta)

- **Fuera de horario:** calls fuera de la franja habitual de Nico (baseline = horas con actividad en los últimos 30 días del propio log; default 07:00-23:00 local si no hay historia). Actividad de madrugada sin sesión de Nico = bandera de posible ejecución no atendida.
- **Tool nunca-visto:** primer uso histórico de un tool → se lista siempre.
- **Ráfaga:** mismo `args_hash` >10 veces en <10 min (loop o abuse — misma lógica que el límite de uso de grants).

Anomalía ≠ incidente: el trail señala, Nico juzga. Si huele a compromise → `/verify-integrity check` + `/karen-audit`.

## Relación con otros commands

- `/karen-audit` = salud del sistema (trust, violations, grants). `/karen-audit-trail` = lupa sobre el log crudo de tools.
- Los grants viven en su propio log (`grants.jsonl`) → `/karen-grant list`.

## Reglas

- Solo lectura — este command JAMÁS modifica el log (append-only, lo escribe solo el hook).
- Export va a `01-MEMORIA/audit/` (gitignored), nunca al repo.
- Si `jq` no está o el log no existe → avisar y salir limpio (igual que degrada el hook).
