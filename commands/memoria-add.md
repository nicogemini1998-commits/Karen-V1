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

## Output

```
✓ Memoria guardada: 01-MEMORIA/<dominio>/AAAA-MM-DD_<tipo>_<slug>_v1.md
✓ Índice actualizado.
✓ Graphify ingest namespace <dominio>.
```
