---
description: Valida credenciales y MCPs ANTES de construir features que dependan de ellos. Evita bloqueos 401 a mitad de build.
---

# /verify-creds

Antes de construir cualquier cosa que dependa de un proveedor externo, valida el acceso primero. Para `$ARGUMENTS` (o la tarea actual).

## Comportamiento

1. Lista los servicios/credenciales que la tarea necesita (Notion, Google Calendar, Gmail, GitHub token, API keys de terceros).
2. Para cada uno ejecuta una prueba mínima de acceso:
   - MCPs → `claude mcp list` (estado Connected vs Needs authentication) + 1 llamada read-only.
   - API keys → un auth check mínimo (request de validación).
3. Reporta una tabla: **servicio | estado (✓/✗) | qué falta**.
4. Si algo falla → **NO empieces el build dependiente.** Dile a Nico la credencial exacta que falta y dónde va.

## Por qué

Del informe de uso: un build se bloqueó por una API key inválida (401) detectada tarde, tras horas de trabajo. Validar al inicio ahorra ese coste.

## Conexiones

- [[Stack — MCP & Agentes]]
- [[Reglas operativas]]
- [[verify-integrity]]
- [[karen-secrets-rotation]]
- [[_MAPA-CEREBRO]]
