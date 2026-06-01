# Stack Personal — Side Projects Nico

> Stack que Nico usa para side projects. Karen referencia esto al crear proyecto nuevo.

---

## Frontend

| Capa | Tool | Notas |
|---|---|---|
| Framework | Next.js (App Router) | TS estricto |
| Lenguaje | TypeScript | `strict: true` |
| Styling | Tailwind CSS | + plugins (forms, typography, container-queries) |
| UI primitives | Radix UI | Dialog, Dropdown, Tabs, Tooltip |
| Iconos | Lucide React | |
| Animaciones | Framer Motion + GSAP | Framer para UI, GSAP para scroll/timeline |
| State | Zustand | Para state cliente complejo |
| Server state | Tanstack Query | Cache + revalidation |
| Forms | React Hook Form + Zod | Validación type-safe |
| 3D (opcional) | Three.js + R3F + Drei | Para hero / decorativo |

---

## Backend

| Capa | Tool | Notas |
|---|---|---|
| API simple | Next.js API Routes | Para side projects monolíticos |
| API compleja | FastAPI (Python) | Cuando lógica pesada |
| Auth | Clerk / NextAuth | Según proyecto |
| DB | Supabase / Postgres | Supabase para rápido, Postgres directo para control |
| ORM | Drizzle / Prisma | Drizzle preferido |
| Cache | Redis | |
| Queue | BullMQ (Node) / Celery (Python) | |

---

## Infra

| Capa | Tool | Notas |
|---|---|---|
| Containers | Docker + Docker Compose | Desde día 1 |
| Deploy frontend | Vercel | Default Next.js |
| Deploy backend | VPS (Hetzner/DigitalOcean) | Cuando control >> ergonomía |
| Reverse proxy | Nginx | |
| TLS | Let's Encrypt | Auto-renew con certbot |
| CI/CD | GitHub Actions | |
| Monitoring | Plausible / Umami + simple healthchecks | Privacy-first analytics |

---

## Tooling dev

| Capa | Tool |
|---|---|
| Editor | Claude Code Desktop + VS Code |
| Package manager | pnpm preferred (`npm` fallback) |
| Linter | ESLint + Prettier |
| Type check | tsc --noEmit en CI |
| Tests | Vitest (unit) + Playwright (e2e) |
| Git | gh CLI + lazygit cuando hace falta |

---

## Convenciones código

### TypeScript
- `strict: true` siempre.
- No `any`. Si imposible → `unknown` + narrow.
- Inferencia preferida, anotaciones solo en boundaries (params functions exportadas, return types públicos).

### Estilos
- Tailwind utility-first.
- CSS custom properties para tokens design system.
- `oklch()` para colores cuando hace falta precisión.
- `clamp()` para tipografía fluida.

### Animaciones
- Solo `transform`, `opacity`, `clip-path`, `filter`.
- NUNCA animar layout (width, height, margin, padding).
- `will-change` narrow + remove cuando acaba.

### Component organization
- Por feature/surface, no por tipo.
- Componente principal + sub-componentes + CSS específico en misma carpeta.

### Naming
- Componentes: `PascalCase` (`HeroSection.tsx`).
- Hooks: `useFoo` (`useScrollProgress.ts`).
- Utils: `camelCase` (`formatDate.ts`).
- CSS classes: kebab-case o utility Tailwind.

### Arquitectura
- KISS > clever.
- DRY pero solo cuando repetición real, no especulativa.
- YAGNI estricto.
- File size: 200-400 típico, 800 max.

---

## Skeleton mental para side project nuevo

```
mi-side-project/
├── README.md
├── .env.example
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── package.json
├── tsconfig.json
├── next.config.ts
├── tailwind.config.ts
├── postcss.config.mjs
├── eslint.config.mjs
├── prettier.config.mjs
└── src/
    ├── app/                ← App Router pages
    │   ├── layout.tsx
    │   ├── page.tsx
    │   └── globals.css
    ├── components/         ← Por feature
    │   ├── hero/
    │   ├── nav/
    │   └── ui/             ← Radix wrappers + primitives propias
    ├── hooks/
    ├── lib/                ← utils, db, integrations
    ├── styles/             ← tokens, typography
    └── types/
```

---

## Decisiones por defecto

| Pregunta | Default |
|---|---|
| ¿Monorepo o polirepo? | Polirepo para side projects single-app. Monorepo solo si >2 apps relacionadas. |
| ¿SSR/SSG/CSR? | SSG por defecto. SSR cuando data necesita ser fresca por request. |
| ¿Auth? | Clerk para rápido. NextAuth si quieres control + DB propia. |
| ¿Self-host o managed? | Managed primero (Vercel, Supabase). Self-host cuando justificación clara. |
| ¿Dark/Light? | Ambos si justificado. NO default dark sin razón. |
