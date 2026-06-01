---
description: Ver estado actual portafolio finanzas. Pull de 03-FINANZAS/portafolio.md + análisis ligero.
---

# /portafolio

Mostrar estado portafolio Nico para `$ARGUMENTS` (default: resumen completo).

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
5. Si Nico pide decisión a partir de esto → activar agente `finanzas-sparring`.

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

## Privacidad

- Esto NUNCA sube al repo (`03-FINANZAS/portafolio.md` gitignored).
- Output solo en sesión, no logear externo.
