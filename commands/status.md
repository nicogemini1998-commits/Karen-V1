---
description: Reporta el estado real de agentes en background y fases en curso, verificando IDs antes de referenciarlos.
---

# /status

## Comportamiento

1. Lista los agentes lanzados en esta sesión con su **ID real** (verificado del contexto, **nunca inventado**).
2. Para cada agente: tarea, estado (corriendo / terminado / muerto), último resultado conocido.
3. Lista las fases del trabajo actual (del TodoWrite) con su estado.
4. Si un ID de agente **no existe** en el contexto → dilo explícito, no asumas que existe.

## Por qué

Del informe de uso: el tracking de agentes falló porque se referenciaron IDs que no existían en el contexto de sesión. Regla: nunca referenciar un ID de agente sin verificarlo primero.

## Conexiones

- [[WORKFLOWS]]
- [[phase]]
- [[karen-orchestrator]]
- [[Reglas operativas]]
- [[_MAPA-CEREBRO]]
