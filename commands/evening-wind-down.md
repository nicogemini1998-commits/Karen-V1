---
description: Cierre de día MANUAL. Fan-out dev + finanzas + productividad → digest wins/bloqueado/mañana. Auto-save a memoria + TODOs pendientes.
---

# /evening-wind-down

Cierre de día. **Manual siempre** — Nico lo lanza cuando termina, Karen no decide cuándo acaba su día.

## Comportamiento

Karen orchestrator lanza en paralelo (Task tool, mismo bloque — igual que `/morning-brief`):

1. **karen-dev** → qué se cerró hoy (commits, PRs, deploys), qué quedó roto/bloqueado, TODOs abiertos.
2. **karen-finance** (solo con flag `--finance`) → movimientos/decisiones del día pendientes de registrar.
3. **productividad** → repasa `01-MEMORIA/productividad/AAAA-MM-DD_morning-brief.md` de hoy: ¿qué prometía el día vs qué pasó?

Espera todos (timeout 120s; fallo → sección `[⚠ STALE]`, el digest sale igual — misma regla que morning-brief).

Sintetiza digest único:

```
🌙 EVENING WIND-DOWN — 2026-06-15 LUN

✅ WINS
────────
- Tests proyecto Y arreglados + deploy staging.
- Research uranium guardado en memoria.

⚠ BLOQUEADO
────────
- PR proyecto X sin review (espera a Toni).
- Modelo 720: falta dato broker <pendiente Nico>.

🎯 MAÑANA
────────
1. Merge PR X si hay review.
2. Llamar gestor (Modelo 720).
3. Revisión spaced repetition pendiente.
```

## Auto-save (sin preguntar)

1. Digest completo → `01-MEMORIA/productividad/AAAA-MM-DD_evening.md` (frontmatter `domain: productividad`, `type: reference`, `date`).
2. TODOs pendientes (lo de ⚠ + 🎯) → append a `01-MEMORIA/TODO.md` con fecha. Sin duplicar: si el TODO ya existe, se actualiza su estado, no se re-añade.
3. Confirmar a Nico con ambos paths.

`/morning-brief` del día siguiente lee `TODO.md` + el último `_evening.md` — el ciclo se cierra solo.

## Args opcionales

- `--finance` incluye sección finanzas (mismo opt-in que morning-brief).
- `--quick` solo digest, sin fan-out (usa lo que Karen ya tiene en contexto de la sesión).

## Reglas

- Cero invención: si un subagent no devuelve datos, la sección dice "sin datos" — Karen no rellena wins imaginarios.
- Salud nunca aparece por default (T2 privado).
- Todo queda en `01-MEMORIA/` (gitignored), nada al repo.
