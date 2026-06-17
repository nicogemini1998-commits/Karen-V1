---
description: Vista combinada agenda Outlook (empresa, read-only) + Gmail Calendar (personal). Muestra eventos cronológicos.
---

# /agenda

Vista combinada calendario empresa + personal para `$ARGUMENTS` (default: hoy).

Valores comunes:
- `hoy`
- `mañana`
- `semana`
- `mes`
- `<fecha específica>`

## Comportamiento

1. Query Outlook empresa (read-only) — eventos del rango.
2. Query Gmail Calendar personal — eventos del rango.
3. Combinar cronológicamente.
4. Etiquetar cada evento:
   - `[Empresa]` — Outlook
   - `[Personal]` — Gmail
5. Marcar conflictos solapados.
6. NO modificar Outlook empresa nunca.

## Output

```
AGENDA — <rango>

LUN 2026-06-15
────────────────────────────
09:00  [Empresa] Standup Cliender
11:00  [Personal] Gym
13:00  [Empresa] Reunión Toni
18:00  [Personal] Médico
────────────────────────────

MAR 2026-06-16
────────────────────────────
...

⚠ Conflictos: ninguno
Eventos: <N> total
```

## Si pide editar

- Personal (Gmail) → OK editar.
- Empresa (Outlook) → "Eso es empresa. Edita desde tu cuenta Cliender."

## Conexiones

- [[Dominio — Productividad]]
- [[04_Productividad]]
- [[Reglas operativas]]
- [[morning-brief]]
- [[_MAPA-CEREBRO]]
