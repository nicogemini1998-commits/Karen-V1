---
description: Brief mañanero. Fan-out paralelo a subagents dev + finanzas + agenda + research. Output digest único.
---

# /morning-brief

Resumen mañanero estructurado. Fan-out paralelo subagents.

## Comportamiento

Karen orchestrator lanza en paralelo:

1. **karen-agenda** → eventos hoy combinados Outlook empresa + Gmail personal.
2. **karen-dev** → estado proyectos activos: builds rotos, PRs pending, TODOs alta prioridad.
3. **karen-finance** (opcional flag `--finance`) → mercados overnight relevantes + portafolio drift.
4. **karen-research** → noticias 24h en topics watch (configurables `profile.json`).
5. **karen-learn** → próxima revisión spaced repetition pendiente.

Espera todos. Sintetiza digest único.

## Output

```
☕ MORNING BRIEF — 2026-06-15 LUN

📅 AGENDA HOY
────────────────
09:00 [Empresa] Standup Cliender
11:00 [Personal] Gym
13:00 [Empresa] Reunión Toni
18:00 [Personal] Médico

⚠ Conflictos: ninguno

💻 DEV
────────
- Proyecto X: build verde, 1 PR review pending.
- Proyecto Y: tests fallan en CI (auth.test.ts línea 42).
- TODOs alta prioridad: deploy staging Y antes viernes.

💰 FINANZAS (--finance)
────────
Overnight relevante (tópicos watch):
- Uranium ETFs URA -1.2%
- Tech NASDAQ +0.8%
Portafolio drift: dentro target (cash 18%, allocation OK).

📚 APRENDIZAJE
────────
Pendiente revisión hoy:
- "GraphRAG fundamentals" (+7d) — review activo.

📰 RESEARCH (topics watch)
────────
- Anthropic released Skills 2.0 (link).
- LightRAG paper update (link).

🎯 SUGERENCIA KAREN
────────
Foco hoy: arreglar tests Y antes standup, deploy staging post-Toni.
```

## Args opcionales

- `--finance` incluye finanzas (sino skip por privacidad / focus).
- `--no-research` skip noticias.
- `--minimal` solo agenda + dev TODOs.
- `--detailed` expande cada sección.

## Configuración tópicos watch

`~/.claude/karen/profile.json` campo `topics_watch`:

```json
{
  "topics_watch": {
    "dev": ["Claude Code", "Next.js 15", "Anthropic API"],
    "finanzas": ["uranium ETFs", "AI semis", "EUR/USD"],
    "aprendizaje": ["GraphRAG", "Mem0", "agent harness"]
  }
}
```

## Privacidad

- Finanzas opt-in (`--finance`).
- Salud nunca en morning-brief default (T2 privado).
- Todo digest queda en `01-MEMORIA/productividad/AAAA-MM-DD_morning-brief.md` (gitignored).

## Conexiones

- [[Dominio — Productividad]]
- [[agenda]]
- [[research]]
- [[Reglas operativas]]
- [[_MAPA-CEREBRO]]
