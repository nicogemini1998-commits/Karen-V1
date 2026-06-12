---
description: Reflexión semanal (domingo). Wins, learnings y fricciones con Karen por dominio + delegation audit. Output a memoria productividad.
---

# /deep-reflection

Reflexión semanal. Pensado para domingo, pero corre cuando Nico quiera.

## Comportamiento

### Fase 1 — Recolectar la semana

Karen lee (sin fan-out — esto es lectura de memoria, no research):

- `01-MEMORIA/productividad/AAAA-MM-DD_evening.md` de los últimos 7 días.
- `01-MEMORIA/productividad/AAAA-MM-DD_morning-brief.md` de la semana.
- `~/.claude/karen/rules-learned.md` + `captures.jsonl` (correcciones de la semana = fricciones reales).
- Entradas nuevas en `01-MEMORIA/<dominio>/` de la semana.

### Fase 2 — Reflexión por dominio

Para cada dominio con actividad esta semana:

```
🪞 DEEP REFLECTION — semana 2026-W25

💻 DEV
────────
Wins:       deploy staging Y, 12 commits, 0 builds rotos al cierre.
Learnings:  esbuild --format=iife obligatorio en prototipos (→ ya en memoria).
Fricciones con Karen: 2 correcciones (sugirió npm en vez de pnpm; olvidó citation).

💰 FINANZAS
────────
Wins:       portafolio actualizado, research uranium cerrado.
Learnings:  —
Fricciones con Karen: 0.

📚 APRENDIZAJE
────────
...
```

"Fricciones con Karen" sale de datos (`captures.jsonl`), no de la percepción de Karen — y Karen pregunta a Nico si falta algo que el hook no capturó.

### Fase 3 — Delegation audit

Pregunta fija, cada semana:

```
🤝 DELEGATION AUDIT
────────
¿Qué 3 cosas repetitivas hiciste esta semana que Karen podría asumir?

Candidatas que detecté yo:
1. <patrón repetido visto en evenings, ej. "copiar TODOs a mano">
2. <...>
3. <...>

¿Cuáles delegas? Cada una se convierte en regla, skill o command.
```

Lo que Nico delegue → entrada en memoria + propuesta concreta de implementación (command nuevo, hook o regla en `rules-learned.md`).

### Fase 4 — Guardar

Output completo → `01-MEMORIA/productividad/AAAA-WW_reflection.md` (semana ISO, ej. `2026-W25_reflection.md`) con frontmatter `domain: productividad`, `type: reference`, `date`.

Actualizar `01-MEMORIA/MEMORY.md` con enlace.

## Scheduling

Programable con `/loop` o cron (ej. domingo 19:00). **NO con Stop hook** — los Stop hooks disparan al cerrar sesión, no por horario; un domingo sin sesión = reflexión que nunca corre. Si la semana pasa sin reflexión, Karen lo menciona en el próximo `/morning-brief` (no insiste más de una vez).

## Reglas

- Reflexión ≠ audit de sistema: para trust scores y violations está `/karen-audit`. Esto va de Nico, su semana y la relación de trabajo con Karen.
- Cero datos inventados: semana sin evenings guardados → "semana sin registro" y se reflexiona solo con lo que haya.
- Privado T2: nada de esto sale de `01-MEMORIA/` (gitignored).
