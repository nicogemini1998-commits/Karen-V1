# 📅 Productividad & Agenda

**Estado:** 🔵 Operación diaria · Hub de planificación

---

## De qué se trata

El sistema nervioso del día a día. Notion es el **hub central** donde converge todo: la agenda combinada (Google personal + Outlook empresa en **read-only**), las tareas por dominio y el plan diario. El objetivo es que cada mañana sepas en 30 segundos qué toca, sin saltar entre cinco apps.

---

## Cómo lo construimos

- **Base de datos `db_Agenda_Tareas`:** cada tarea/bloque con fecha, hora, dominio asociado y estado. Es la lista única de la verdad.
- **Agenda combinada:**
  - **Google Calendar personal** → lectura y escritura.
  - **Outlook empresa** → **solo lectura**. Nunca se escribe ahí desde aquí (aislamiento Cliender).
  - Vista unificada cuando preguntes "qué tengo hoy/esta semana".
- **Bloques por dominio:** cada tarea se etiqueta con su dominio (Finanzas, Salud, IA, Dev…) para ver el reparto de energía.
- **Daily plan:** un bloque al inicio del día que prioriza 1-3 tareas críticas, no una lista infinita.

---

## Qué necesito de ti

- Mantener `db_Agenda_Tareas` con lo importante (no hace falta micro-gestionar todo).
- Conectar **Google Calendar** (escritura) y **Outlook empresa** (solo lectura) cuando montemos el MCP.
- Decirme tus **horas de máxima energía** para colocar ahí lo difícil (deep work IA/dev).
- Marcar tareas como **Hecho** para que el sistema mida progreso real.

---

## Qué esperar de Karen

- **Vista combinada** de Google + Outlook cuando pidas tu agenda, sin tocar nunca el calendario de empresa.
- **Plan diario propuesto:** te sugiero las 1-3 prioridades del día según metas norte y deadlines.
- **Defensa del foco:** te aviso si estás llenando el día de tareas de bajo impacto y descuidando las metas.
- **Reparto por dominio:** te muestro cuántas horas van a cada meta para detectar desequilibrios.
- **Ejecución directa:** en agenda no hago sparring; ejecuto y propongo.

---

## Cómo lo mejoramos

- **Semana 1:** poblar `db_Agenda_Tareas` y conectar Google Calendar.
- **Semana 2:** añadir Outlook empresa en read-only y validar vista combinada.
- **Continuo:** revisión semanal (qué se hizo, qué se arrastró, por qué).
- **Automatizar:** que Karen genere el daily plan cada mañana leyendo calendarios + tareas vía MCP.
- **Norte:** que cada bloque de tiempo esté alineado con una de las 3 metas, no con apagar fuegos.
