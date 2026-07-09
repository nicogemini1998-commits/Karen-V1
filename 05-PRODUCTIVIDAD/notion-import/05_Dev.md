# 💻 Dev & Side Projects

**Estado:** 🔵 Taller personal · Alimenta Finanzas y Aprendizaje IA

---

## De qué se trata

El taller personal de Nico, **completamente aislado de Cliender**. Aquí viven los side projects: experimentos, productos propios y proyectos-ancla del roadmap de IA. Es la fábrica donde el aprendizaje se convierte en código que se puede mostrar y vender. Stack base: **Next.js + Tailwind + Docker**, con Python/FastAPI y N8N cuando aplica.

---

## Cómo lo construimos

- **Estructura aislada:** todo proyecto vive en `02-DEV/proyectos-activos/<AAAA-MM-DD_slug>/`. Cero código, credenciales o contexto de empresa.
- **Stack por defecto:** Next.js + Tailwind + Framer Motion + Zustand + TanStack Query. Docker compose desde el día 1.
- **Conexión con IA:** cada capa del roadmap de `03 Aprendizaje IA` cierra con un proyecto aquí que demuestra el concepto (agente, MCP server, vertical AI).
- **Conexión con Finanzas:** los proyectos que generan ingresos se registran como fuente en `db_Fuentes_Ingreso`.
- **GitHub personal:** repos bajo `nicogemini1998-commits`, nunca mezclados con la cuenta de empresa.

---

## Qué necesito de ti

- Decirme la **idea** y el objetivo del proyecto (¿aprendizaje, producto, o cliente?).
- Confirmar que es **personal** (si roza Cliender, va a la cuenta empresa, no aquí).
- Tu **GitHub token personal** cuando montemos automatización de repos.
- Prioridad: ¿este proyecto empuja Finanzas, Aprendizaje IA, o ambos?

---

## Qué esperar de Karen

- **Plan antes de código:** estructuro el proyecto (`/plan`) antes de tocar una línea.
- **Mejora, no sustituye:** refactor que preserva lo que funciona; nada de reescribir por reescribir.
- **Docker first** y código en inglés, sin comentarios decorativos ni sobreingeniería.
- **Code-review + simplify** antes de cualquier commit.
- **Sparring de arquitectura** en decisiones de diseño; opciones + recomendación en el resto.
- **Firewall Cliender:** si algo huele a empresa, paro y te aviso.

---

## Cómo lo mejoramos

- **Por proyecto:** plan → scaffold → build → review → commit → registrar en memoria + Graphify.
- **Reutilización:** extraer plantillas de lo que se repite (auth, MCP server base, dashboards).
- **Pipeline aprendizaje → dev → ingresos:** cada proyecto-ancla que funcione se evalúa como posible fuente de ingreso.
- **Automatizar:** scaffolding de proyectos con un comando, Docker compose preconfigurado.
- **Norte:** que el taller produzca al menos un proyecto vendible alineado con vertical AI.
