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

## Boundary explícito: Outlook empresa vs Gmail personal

| | Outlook (empresa) | Gmail (personal) |
|---|---|---|
| Acceso | **READ-ONLY** | Read/write (write con confirm) |
| Token | Separado — cuenta Microsoft 365 Cliender, scope solo lectura | Token personal de Nico |
| Karen puede | Listar eventos, detectar conflictos | Listar, crear, mover, borrar eventos |
| Karen NUNCA | Crear/editar/borrar, leer adjuntos, responder invitaciones | — |

**Por qué (aislamiento Cliender):** Karen es el agente PERSONAL de Nico. Si Karen tuviera write sobre la cuenta empresa, un prompt injection o un fallo de Karen podría modificar/filtrar datos corporativos — y los datos Cliender se quedarían mezclados en memoria personal. Token read-only separado = blast radius cero hacia la empresa. Refuerza el hook `cliender-isolation-guard.sh`.

## Si pide editar

- Personal (Gmail) → OK editar (con confirm antes de escribir).
- Empresa (Outlook) → "Eso es empresa. Edita desde tu cuenta Cliender." Sin excepciones — ni con grant.

## Conexiones

- [[Dominio — Productividad]]
- [[04_Productividad]]
- [[Reglas operativas]]
- [[morning-brief]]
- [[_MAPA-CEREBRO]]
