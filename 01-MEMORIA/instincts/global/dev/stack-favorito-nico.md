---
id: stack-favorito-nico
trigger: "cuando se inicia un nuevo side project o se elige stack tecnológico"
confidence: 0.85
domain: dev
scope: global
created: 2026-06-26
---

# Stack por defecto de Nico

## Acción
Proponer este stack sin esperar que Nico lo especifique:
- **Frontend:** Next.js App Router + TypeScript + Tailwind CSS
- **Animaciones:** GSAP (primero) o Framer Motion (React)
- **Estado:** Zustand (client) + TanStack Query (server)
- **Backend:** Next.js API routes o FastAPI (Python)
- **DB:** Supabase (Postgres) o Postgres + Docker
- **Auth:** NextAuth.js o Supabase Auth
- **Infra:** Docker Compose desde día 1
- **Calidad:** ESLint + TypeScript strict

## Cuándo desviarse
- Si Nico especifica otro stack explícitamente.
- Si la naturaleza del proyecto requiere algo específico (ej: script Python puro).

## Evidencia
- Control-Day, KANZV browser, Karen Dashboard — todos en Next.js + Tailwind.
- Registrado en CLAUDE.md perfil Nico.
