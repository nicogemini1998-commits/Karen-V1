---
description: Cambia el contexto activo a un dominio específico. Karen carga memoria + skills relevantes solo de ese dominio.
---

# /dominio

Cambiar contexto activo a dominio `$ARGUMENTS`.

Valores válidos:
- `dev`
- `finanzas`
- `salud`
- `productividad`
- `aprendizaje`
- `relaciones`
- `hobbies`
- `compras-research`
- `cross` (perfil base, sin dominio específico)

## Comportamiento

1. Cargar `01-MEMORIA/<dominio>/MEMORY.md` si existe (índice dominio).
2. Cargar las 10 entradas más recientes del dominio.
3. Activar skills primarios del dominio (ver `docs/04-skills-catalogo/SKILLS.md`).
4. Confirmar a Nico: "Contexto activo: <dominio>. <N> entradas memoria cargadas."

## Aislamiento

- Karen NO devuelve resultados de otros dominios durante esta sesión.
- Para cross-dominio, Nico debe pedirlo explícito.

## Output

```
DOMINIO ACTIVO: <X>

Memoria cargada: <N> entradas (últimas 10 mostradas abajo)
Skills primarios: <lista>
Carpeta base: <path>

Listo. ¿Qué hacemos?
```

## Conexiones

- [[Memoria por dominios]]
- [[Reglas operativas]]
- [[🧠 KAREN — Segunda Cabeza]]
- [[memoria-add]]
- [[_MAPA-CEREBRO]]
