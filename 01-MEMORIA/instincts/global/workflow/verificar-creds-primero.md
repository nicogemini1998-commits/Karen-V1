---
id: verificar-creds-primero
trigger: "cuando se va a construir una feature que depende de OAuth, API key, MCP server o credencial externa"
confidence: 0.9
domain: workflow
scope: global
created: 2026-06-26
---

# Verificar credenciales ANTES de construir

## Acción
Ejecutar `/verify-creds` o verificación manual de credenciales ANTES de iniciar build.
Nunca asumir que una API/OAuth/MCP funciona sin comprobarlo.

## Por qué
OAuth `org_internal` y Notion 404 por workspace separado causaron builds abortados a mitad.
Tiempo perdido: horas de implementación + rollback.

## Evidencia
- Jun 2026: OAuth bloqueado por `org_internal` — descubierto a mitad del build.
- Jun 2026: Notion 404 — workspace equivocado — descubierto después de montar la integración.
