---
id: orden-archivos-nico
trigger: "cuando se va a crear cualquier archivo o directorio"
confidence: 0.95
domain: workflow
scope: global
created: 2026-06-26
---

# Orden absoluto — nada suelto jamás

## Acción
Antes de crear cualquier archivo:
1. Identificar dominio (dev, finanzas, salud, etc.)
2. Colocarlo en la carpeta numerada correspondiente
3. Naming: `AAAA-MM-DD_TIPO_descripcion_vN.ext`
4. Nunca en la raíz del repo (excepto CLAUDE.md, README.md, _ATAJOS.md, dot-files, carpetas numeradas)

## Estructura raíz permitida
```
CLAUDE.md, README.md, _ATAJOS.md, CHANGELOG.md
00-SISTEMA-KAREN/, 01-MEMORIA/, 02-DEV/, ..., 10-GRAPHIFY/
.git/, .claude/, .gitignore, etc.
```

## Lo que NO hacer
- Crear archivo en raíz → moverlo inmediatamente
- Usar nombres sin fecha o sin tipo (`notas.md`, `test.js`)
- Mezclar dominios en una carpeta

## Evidencia
- Regla inviolable desde v1.0 de Karen.
- Registrado en CLAUDE.md reglas operativas.
