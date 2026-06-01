# KAREN AI P.A

> Personal AI Assistant — estilo JARVIS (Tony Stark) + FRIDAY (Spider-Man).
> Aislada por dominios. Memoria persistente con Graphify.

---

## 🚀 Instalación en ordenador nuevo (1 comando)

```bash
git clone https://github.com/nicogemini1998-commits/KAREN-V1.git ~/karen-personal
cd ~/karen-personal
bash scripts/install.sh
```

Eso descarga el repo, crea la estructura, instala plugins/MCPs sugeridos y deja a Karen lista para arrancar.

### Después de instalar

1. Abre Claude Code Desktop.
2. Apunta a `~/karen-personal/`.
3. Karen lee `CLAUDE.md` automáticamente y ejecuta onboarding.
4. Te pide los datos faltantes (broker, GitHub, Notion, etc.).
5. Listo.

---

## 📚 Qué hay en este repo

| Carpeta | Para qué |
|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | Puerta principal. Karen lo lee al abrir el proyecto. |
| [`_ATAJOS.md`](./_ATAJOS.md) | Hub rutas rápidas. |
| [`docs/`](./docs) | Documentación completa — quién soy, personalidad Karen, arquitectura, skills, workflow. |
| [`templates/`](./templates) | Plantillas listas para copiar (settings.json, hooks, estructura carpetas). |
| [`scripts/`](./scripts) | Scripts de instalación y mantenimiento. |
| [`agents/`](./agents) | Agentes Claude personalizados (architect, code-reviewer, finanzas-sparring, etc.). |
| [`commands/`](./commands) | Comandos slash custom (`/plan`, `/build-fix`, `/sparring`, etc.). |

---

## 📖 Lectura obligada antes de usar

En orden:

1. [`docs/01-quien-soy/PERFIL_NICO.md`](./docs/01-quien-soy/PERFIL_NICO.md) — Quién es Nico, cómo trabaja, qué le revienta.
2. [`docs/02-personalidad-karen/IDENTIDAD.md`](./docs/02-personalidad-karen/IDENTIDAD.md) — Personalidad Karen, tono, modo decisión.
3. [`docs/03-arquitectura/ESTRUCTURA.md`](./docs/03-arquitectura/ESTRUCTURA.md) — Estructura carpetas, dominios aislados, memoria.
4. [`docs/04-skills-catalogo/SKILLS.md`](./docs/04-skills-catalogo/SKILLS.md) — Skills disponibles por tier.
5. [`docs/05-workflow/WORKFLOWS.md`](./docs/05-workflow/WORKFLOWS.md) — Flujos típicos por dominio.

---

## 🛡️ Privacidad

**Este repo es público pero cero info personal sensible.**

- ❌ NO contiene emails, tokens, API keys, credenciales, datos médicos, financieros reales.
- ✅ Contiene: estructura, personalidad, configuración base, skills, templates.
- Todo lo sensible queda en `.gitignore` y vive solo en tu máquina local (`~/karen-personal/01-MEMORIA/`).

Ver [`.gitignore`](./.gitignore) para detalles.

---

## 🧬 Personalidad Karen (resumen)

- **Estilo:** JARVIS + FRIDAY. Técnica, directa, sin pleasantries.
- **Tono:** Colega en casual. Sparring socrático en finanzas/salud/compras/carrera.
- **Idioma:** Español base, mix ES-EN según contexto técnico.
- **Modo decisión:** Opciones + recomendación. Tú decides.
- **Lealtad:** Esclava de la verdad, no inventa datos.
- **Aislamiento:** Cero contacto con Cliender (cuenta empresa separada).

---

## 🗂️ Dominios aislados

Memoria + carpetas separadas:

```
dev · finanzas · salud · productividad · aprendizaje · relaciones · hobbies · compras-research
```

Lo que pasa en `finanzas` no se mezcla con `dev`. Cross-dominio solo si tú pides explícito.

---

## 📦 Versión

**v1.0** · 2026-06-01 · Initial release
