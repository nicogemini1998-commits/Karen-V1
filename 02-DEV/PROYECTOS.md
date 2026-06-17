# 02-DEV · Registro de proyectos y puertos

> Regla: **cada proyecto tiene su carpeta, su Docker y un puerto asignado aquí.** Antes de arrancar un dev server, Karen consulta esta tabla para no pisar puertos ni dejar puertos abiertos sin necesidad. Al terminar de trabajar, se detiene el server (libera el puerto).

## Mapa de puertos

| Proyecto | Carpeta | Puerto dev | Docker | Estado |
|---|---|---|---|---|
| **Control-Day** (dashboard de vida) | `proyectos-activos/control-day/` | **3000** | ✅ Dockerfile + compose | Activo |
| _(libre)_ | — | 3001 | — | — |
| _(libre)_ | — | 3002 | — | — |
| _(libre)_ | — | 3003 | — | — |

## Convención para proyectos nuevos
1. Carpeta en `proyectos-activos/<nombre-slug>/`.
2. **Docker desde día 1**: `Dockerfile` (multi-stage) + `docker-compose.yml` + `.dockerignore`.
3. Asignar el **siguiente puerto libre** de la tabla y fijarlo en `package.json` (`next dev -p <puerto>`) y en `docker-compose.yml`.
4. Registrar el proyecto en esta tabla (puerto, docker, estado).
5. Al terminar la sesión de trabajo: **detener el dev server** (`lsof -ti:<puerto> | xargs kill`) para no dejar puertos abiertos.

## Comandos útiles
```bash
# Ver qué hay en un puerto
lsof -ti:3000
# Liberar un puerto
lsof -ti:3000 | xargs kill
# Arrancar Control-Day (dev)
cd proyectos-activos/control-day && pnpm dev      # → :3000
# Arrancar Control-Day (Docker, producción)
cd proyectos-activos/control-day && docker compose up --build
```
