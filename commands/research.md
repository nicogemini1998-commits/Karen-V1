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
