---
description: Añade entrada a memoria etiquetada por dominio. Auto-graphify ingest.
---

# /memoria-add

Añadir entrada memoria. Args: `<dominio> <tipo> <título>`.

Dominios: dev, finanzas, salud, productividad, aprendizaje, relaciones, hobbies, compras-research, cross.

Tipos: profile, preference, decision, incident, research, reference.

## Ejemplo

```
/memoria-add finanzas decision "Abrir cuenta Trade Republic con 1000€"
```

## Comportamiento

1. Crear archivo `01-MEMORIA/<dominio>/AAAA-MM-DD_<TIPO>_<slug>_v1.md`.
2. Frontmatter:
```yaml
---
domain: <dominio>
type: <tipo>
date: AAAA-MM-DD
expires: AAAA-MM-DD | never
tags: []
related: []
---
```
3. Preguntar a Nico:
   - Contexto (1-2 frases).
   - Decisión / hecho.
   - Razón.
   - Cómo aplicar a futuro.
4. Escribir contenido estructurado.
5. Actualizar `01-MEMORIA/MEMORY.md` con enlace.
6. `/graphify ingest <archivo> --namespace <dominio>`.
7. Confirmar a Nico con path archivo.

## Flujo 4 preguntas (si faltan args)

Si Nico lanza `/memoria-add` con args incompletos, Karen pregunta EXACTAMENTE 4 cosas — ni más ni menos:

1. **¿Dominio?** → carpeta destino.
2. **¿Tipo?** → profile, preference, decision, incident, research, reference.
3. **¿Por qué importa?** → va al cuerpo como razón (sin razón no se guarda).
4. **¿Caduca?** → frontmatter `expires: AAAA-MM-DD` o `expires: never`.

### Mini-ejemplo

```
Nico: /memoria-add "prefiero pnpm a npm"

Karen: 4 rápidas:
1. ¿Dominio? (huele a dev)
2. ¿Tipo? (huele a preference)
3. ¿Por qué importa?
4. ¿Caduca?

Nico: 1. dev  2. preference  3. lockfile más rápido y mejor en monorepos  4. no

Karen:
✓ Memoria guardada: 01-MEMORIA/dev/2026-06-12_PREFERENCE_pnpm-sobre-npm_v1.md
✓ expires: never
✓ Índice actualizado.
```

## Output

```
✓ Memoria guardada: 01-MEMORIA/<dominio>/AAAA-MM-DD_<tipo>_<slug>_v1.md
✓ Índice actualizado.
✓ Graphify ingest namespace <dominio>.
```
