# ESTRUCTURA — Carpetas y dominios

> Arquitectura completa Karen Personal en `~/karen-personal/`.

---

## Filosofía

**Dominios aislados.** La vida de Nico se separa en compartimentos. Lo que pasa en `finanzas` no toca `dev`. Lo que pasa en `salud` no toca `productividad`. Cross-dominio solo si Nico pide explícito.

**Raíz limpia.** Solo archivos sistema en raíz. Todo lo demás a carpeta numerada inmediatamente.

**Numeración estricta.** Cada carpeta empieza con número de 2 dígitos para orden visual y mental claro.

---

## Árbol completo

```
~/karen-personal/
│
├── CLAUDE.md                           ← Identidad Karen, onboarding
├── _ATAJOS.md                          ← Hub rutas rápidas
├── README.md                           ← Overview repo
├── .gitignore                          ← Privacidad
│
├── docs/                               ← Documentación completa
│   ├── 01-quien-soy/
│   ├── 02-personalidad-karen/
│   ├── 03-arquitectura/
│   ├── 04-skills-catalogo/
│   └── 05-workflow/
│
├── templates/                          ← Plantillas listas
│   ├── .claude/                        ← settings.json, hooks, etc.
│   └── karen-personal-root/            ← Estructura inicial completa
│
├── scripts/                            ← install.sh, mantenimiento
├── agents/                             ← Agentes Claude custom
├── commands/                           ← Slash commands custom
│
├── 00-SISTEMA-KAREN/                   ← Config interna Karen
│   ├── 01-RULES/                       ← Rules contextuales modulares
│   └── 02-SKILLS/                      ← Notas sobre skills (no las skills)
│
├── 01-MEMORIA/                         ← MEMORIA PERSISTENTE (gitignored)
│   ├── MEMORY.md                       ← Índice global, solo enlaces
│   ├── dev/
│   ├── finanzas/
│   ├── salud/
│   ├── productividad/
│   ├── aprendizaje/
│   ├── relaciones/
│   ├── hobbies/
│   └── compras-research/
│
├── 02-DEV/                             ← Side projects código
│   ├── proyectos-activos/              ← Cada proyecto en subcarpeta dated
│   ├── snippets/                       ← Trozos reutilizables
│   ├── research-tecnica/               ← Notas técnicas (al repo OK)
│   └── stack-personal.md               ← Stack actual + decisiones
│
├── 03-FINANZAS/                        ← Inversiones (gitignored mostly)
│   ├── portafolio.md                   ← Estado actual
│   ├── research-ETFs/                  ← Análisis ETFs concretos
│   ├── fiscalidad-ES/                  ← Notas IRPF, Modelo 720, etc.
│   └── broker-notas/                   ← Notas operativa broker
│
├── 04-SALUD-FITNESS/                   ← Rutinas, tracking (gitignored)
│   ├── rutinas/
│   ├── nutricion/
│   └── tracking/
│
├── 05-PRODUCTIVIDAD/                   ← GTD, sync apps externas
│   ├── notion-sync/
│   ├── calendario-outlook/             ← Empresa (read-only)
│   ├── calendario-gmail/               ← Personal (read/write)
│   └── routines.md                     ← Rutinas mañana/noche
│
├── 06-APRENDIZAJE/                     ← Libros, cursos
│   ├── libros/
│   ├── cursos/
│   ├── idiomas/
│   └── notas-research/
│
├── 07-RELACIONES/                      ← Drafts mensajes (gitignored)
│   └── drafts/
│
├── 08-HOBBIES/                         ← A definir según Nico
│
├── 09-COMPRAS-RESEARCH/                ← Decisiones compra grandes
│
└── 10-GRAPHIFY/                        ← Knowledge graph global
    ├── graph.json                      ← (gitignored)
    ├── corpus/                         ← Documentos ingestados
    └── exports/                        ← Exports queries útiles
```

---

## Regla de creación de archivos

**Antes de crear un archivo, Karen pregunta:**

1. ¿Es dato personal sensible (finanzas, salud, relaciones)? → `01-MEMORIA/<dominio>/` (gitignored).
2. ¿Es código side project? → `02-DEV/proyectos-activos/<AAAA-MM-DD_slug>/`.
3. ¿Es nota técnica reutilizable? → `02-DEV/snippets/` o `02-DEV/research-tecnica/`.
4. ¿Es nota aprendizaje pública? → `06-APRENDIZAJE/<sub>/`.
5. ¿Es draft mensaje? → `07-RELACIONES/drafts/`.
6. ¿Es decisión compra? → `09-COMPRAS-RESEARCH/`.
7. **¿No encaja en ninguna?** → preguntar a Nico antes de crear.

**Nunca:** soltar en raíz.

---

## Convenciones

### Naming archivos
```
AAAA-MM-DD_TIPO_descripcion_vN.ext
```

Ejemplos:
- `2026-06-15_RESEARCH_etf-vanguard-vwce_v1.md`
- `2026-07-01_DECISION_broker-trade-republic_v2.md`
- `2026-08-10_PROYECTO_dashboard-finanzas_v1/`

### Naming carpetas dominio
- Numeradas 2 dígitos: `01-`, `02-`, ... `10-`.
- Sin espacios: usar guiones (`SALUD-FITNESS`, no `SALUD FITNESS`).
- Mayúsculas para dominios top-level, minúsculas para sub.

### `.gitkeep` para carpetas vacías
Cualquier carpeta gitignored que debe existir en estructura inicial lleva un `.gitkeep` para que git la track.

---

## Diferencia repo (público) vs local (Nico)

### En el repo público GitHub
- Estructura + templates + docs + scripts.
- **CERO datos personales.** Solo `.gitkeep` en dominios sensibles.

### En el ordenador Nico (después de `install.sh`)
- Estructura completa + carpetas vacías listas para usar.
- Karen va llenando memoria conforme Nico trabaja.
- Memoria nunca sube al repo (gitignored).

---

## Auditoría raíz

Comando one-liner para verificar raíz limpia:

```bash
cd ~/karen-personal
ls -1 | grep -vE '^(CLAUDE\.md|_ATAJOS\.md|README\.md|\.gitignore|docs|templates|scripts|agents|commands|00-|01-|02-|03-|04-|05-|06-|07-|08-|09-|10-)' || echo "✓ Raíz limpia"
```

Si devuelve algún archivo → mover a carpeta numerada.

---

## Migración de archivos sueltos detectados

Si Karen encuentra archivos sueltos en raíz:

1. **Identificar dominio** por contenido.
2. **Crear subcarpeta** si no existe.
3. **Checkpoint** si afecta a >3 archivos.
4. **Mover** archivo.
5. **Actualizar** `_ATAJOS.md` si era acceso útil.
6. **Anotar** en `01-MEMORIA/` con razón.
