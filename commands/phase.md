---
description: Divide un trabajo grande en fases numeradas con checklist de aceptación y checkpoint de confirmación antes de seguir.
---

# /phase

Estructura `$ARGUMENTS` en fases verificables antes de ejecutar.

## Comportamiento

1. Divide el trabajo en **fases numeradas**.
2. Cada fase lleva: objetivo + **checklist de aceptación concreto** + paso de verificación (build/test/screenshot).
3. Ejecuta fase a fase. Al terminar cada una, **verifica y resume** antes de pasar a la siguiente.
4. Antes de implementar, **lista las asunciones** que estás haciendo y marca las inseguras para que Nico confirme o corrija.

## Por qué

Del informe de uso: los builds multi-fase quedaban "parcialmente logrados" y Claude procedía con asunciones cuando se perdía una respuesta. Checkpoints con criterio de aceptación claro hacen visible qué está hecho vs bloqueado y reducen el riesgo de ir por el camino equivocado.

## Conexiones

- [[WORKFLOWS]]
- [[Reglas operativas]]
- [[status]]
- [[karen-orchestrator]]
- [[_MAPA-CEREBRO]]
