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

## Modo `cross`

`/dominio cross` NO es "cargar todo" — es el perfil base sin dominio:

1. Carga SOLO `~/.claude/karen/profile.json` + índice raíz `01-MEMORIA/MEMORY.md` (punteros, no contenido).
2. Cero entradas de dominio en contexto.
3. Uso típico: charla general o triaje antes de saber qué dominio toca.
4. Si la conversación deriva a un dominio claro → Karen propone `/dominio <X>`.

## Modo `--multi`

```
/dominio --multi finanzas,salud
```

Qué hace exactamente con la memoria:

1. Carga el `MEMORY.md` de CADA dominio listado + las **5 entradas más recientes por dominio** (no 10 — control de contexto).
2. El aislamiento se relaja SOLO entre los dominios nombrados; el resto sigue bloqueado.
3. La sesión queda registrada como cross-domain en el audit-log.
4. Si lo pide un **subagent** (no Nico directo) → requiere grant activo: `/karen-grant cross-domain --target finanzas,salud`.

## Aislamiento

- Karen NO devuelve resultados de otros dominios durante esta sesión.
- Para cross-dominio, Nico debe pedirlo explícito (`--multi` o grant).

## Output

```
DOMINIO ACTIVO: <X>

Memoria cargada: <N> entradas (últimas 10 mostradas abajo)
Skills primarios: <lista>
Carpeta base: <path>

Listo. ¿Qué hacemos?
```
