# Sistema de Instintos Karen v2.1

Sistema de aprendizaje continuo basado en ECC Continuous Learning v2.1.

## Estructura
```
instincts/
├── README.md           ← este archivo
├── global/             ← instintos aplicables a todo proyecto
│   ├── workflow/       ← patrones de trabajo con Nico
│   ├── visual/         ← preferencias visuales
│   └── comunicacion/   ← cómo comunicarse con Nico
└── projects/           ← instintos por proyecto (project-hash/)
    └── karen-personal/ ← instintos específicos de Karen
```

## Formato de instinto
```yaml
---
id: slug-unico
trigger: "cuando X"
confidence: 0.0-1.0   # 0.3=tentativo, 0.7=confirmado, 0.9=certero
domain: workflow|visual|comunicacion|dev|finanzas|salud
scope: global|project
project_id: hash-12chars (solo si scope=project)
---
# Título del instinto

## Acción
Qué hacer cuando se activa el trigger.

## Evidencia
- Observación 1 (fecha)
- Corrección de Nico en X
```

## Comandos
- `/instinct-status` — listar instintos activos + confianza
- `/instinct-export` — exportar como YAML
- `/instinct-import` — importar instintos desde otro proyecto
- `/evolve` — agrupar instintos relacionados → skill/comando
- `/promote` — promover instinto de proyecto a global

## Regla de promoción
Si un instinto aparece en 2+ proyectos → promover a `global/`.
Confianza mínima para actuar sin preguntar: 0.7.
