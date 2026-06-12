---
description: Atajo deep-research con scope y dominio explícito. Karen ejecuta investigación multi-fuente verificada y guarda en dominio correcto.
---

# /research

Research multi-fuente sobre `$ARGUMENTS`.

## Comportamiento

1. Si args incluyen `--domain <dev|finanzas|salud|...>` → guardar en ese dominio.
2. Si no → preguntar a Nico antes de empezar.
3. Aclarar scope:
   - **Quick** (15 min): TL;DR + 5 conceptos clave + próximo paso.
   - **Medium** (1-2h): Estructura completa + análisis crítico.
   - **Deep** (>2h): Multi-stage con verificación adversarial.
4. Invocar `deep-research` skill con effort apropiado.
5. Output → `01-MEMORIA/<dominio>/AAAA-MM-DD_RESEARCH_<slug>_v1.md` o carpeta apropiada dominio.
6. `/graphify ingest` namespace dominio.
7. Actualizar `MEMORY.md` con enlace.

## Fallback sin graphify

Si el skill `/graphify` no está disponible o falla → el research NO se pierde:

1. Guardar igualmente el markdown en `01-MEMORIA/<dominio>/AAAA-MM-DD_RESEARCH_<slug>_v1.md` con frontmatter completo:
   ```yaml
   ---
   domain: <dominio>
   type: research
   date: AAAA-MM-DD
   expires: never
   tags: []
   sources: [<urls>]
   graphify: pending
   ---
   ```
2. Actualizar `MEMORY.md` con el enlace (eso sí o sí).
3. Avisar a Nico: "Graphify no disponible — guardado en memoria plana con `graphify: pending`."
4. Próxima sesión con graphify operativo → ingest de todos los `graphify: pending` del dominio.

El graph es un índice; la memoria markdown es la fuente de verdad.

## Reglas

- Cero datos inventados. Citar fuentes.
- Si fuente conflictiva → mostrar discrepancia.
- Preferir fuentes 2024-2026 cuando aplique.
- Verificación adversarial en deep mode.

## Ejemplo

```
/research "uranium ETFs UCITS para perfil retail ES 2026" --domain finanzas
```

Karen:
- Confirma scope (medium probable).
- Ejecuta deep-research.
- Output a `03-FINANZAS/research-ETFs/AAAA-MM-DD_RESEARCH_uranium-etfs-ucits_v1.md`.
- Graphify ingest namespace finanzas.

## Output

```
RESEARCH iniciado: <tema>
Scope: <quick|medium|deep>
Dominio: <X>
Fuentes objetivo: <N>

[ejecución multi-stage]

✓ Research completado.
✓ Guardado: <path>
✓ Graphify ingest namespace <X>.

TL;DR (3 líneas):
- ...
- ...
- ...

¿Quieres deep-dive a algún punto?
```
