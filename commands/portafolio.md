---
description: Ver estado actual portafolio finanzas. Pull de 03-FINANZAS/portafolio.md + análisis ligero.
---

# /portafolio

Mostrar estado portafolio Nico para `$ARGUMENTS` (default: resumen completo).

**Command READ-ONLY.** `/portafolio` solo lee y muestra — nunca escribe en `03-FINANZAS/portafolio.md`.

Valores:
- `resumen` (default) — overview
- `detalle` — todas las posiciones
- `rendimiento` — performance YTD
- `riesgo` — concentración + exposiciones
- `fiscal` — implicaciones IRPF / Modelo 720

## Comportamiento

1. Leer `03-FINANZAS/portafolio.md`.
2. Si vacío → "Sin portafolio registrado. Quieres crearlo? `/memoria-add finanzas profile portafolio-inicial`".
3. Mostrar según vista pedida.
4. Cero recomendaciones (eso es sparring, no /portafolio).
5. Si Nico pide decisión a partir de esto → activar agente `karen-finance`.

## Output (resumen)

```
PORTAFOLIO — actualizado <fecha>

Posiciones: <N>
Valor total: <€X> (cálculo basado en última actualización Nico — verificar precios actuales)
Allocation:
  - Equity:    XX%
  - Bonos:     XX%
  - Cash:      XX%
  - Alt:       XX%

Top 5 holdings:
  1. <ticker> — XX%
  2. ...

⚠ Snapshot Nico — precios pueden estar stale. ¿Refrescar?
```

## Workflow de update (explícito)

El update NO pasa por este command. Flujo:

1. **Nico aporta los datos** — copy-paste del broker, CSV o dictado (posiciones, cantidades, cash).
2. Karen propone el diff sobre `03-FINANZAS/portafolio.md` y **espera confirm**.
3. Confirmado → escribe vía `/memoria-add finanzas profile "portafolio-update-AAAA-MM-DD"`.

**Regla absoluta:** Karen NUNCA inventa posiciones, precios ni cantidades. Si falta un dato → se marca `<pendiente Nico>`, jamás se rellena. Sin datos de Nico no hay update — punto.

## Privacidad

- Esto NUNCA sube al repo (`03-FINANZAS/portafolio.md` gitignored).
- Output solo en sesión, no logear externo.

## Conexiones

- [[Dominio — Finanzas]]
- [[01_Finanzas]]
- [[finanzas-sparring]]
- [[sparring]]
- [[_MAPA-CEREBRO]]
