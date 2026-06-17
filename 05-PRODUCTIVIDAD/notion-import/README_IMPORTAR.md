# Guía de importación a Notion — Panel de Control de Vida

Este paquete contiene todo lo necesario para montar el **Panel de Control de Vida** de Nico en Notion. Sigue los pasos en orden y en menos de 15 minutos tienes el workspace operativo.

---

## 1. Cómo importar (dos métodos)

### Método A — Arrastrar archivos (rápido)
1. Abre Notion (app de escritorio o web).
2. Crea una página vacía nueva donde quieras alojar el panel (o usa una existente).
3. Arrastra los archivos `.md` y `.csv` directamente dentro de la página.
4. Notion los convertirá automáticamente: los `.md` en páginas, los `.csv` en bases de datos.

### Método B — Settings → Import
1. En la barra lateral izquierda, pulsa **Settings** (Configuración).
2. Busca la sección **Import** (Importar).
3. Selecciona **Text & Markdown** para los `.md` y **CSV** para los `.csv`.
4. Selecciona los archivos del paquete y confirma.

---

## 2. Qué crea cada tipo de archivo

- **`.md` → Páginas.** Cada Markdown se convierte en una página de Notion con sus encabezados, listas y negritas.
- **`.csv` → Bases de datos (databases).** Al importar un CSV, Notion ofrece opciones:
  - Elige **"Table"** (tabla) o **"New database"** para crear una base de datos nueva.
  - Usa **"Merge with CSV"** solo si ya tienes una base existente a la que quieres añadir filas.
  - Tras importar, ajusta el **tipo de cada columna** (número para importes/pesos, fecha para fechas, select para estados). Notion las crea como texto por defecto.

---

## 3. Orden recomendado de importación

1. `00_HUB_Karen.md` — la portada del sistema. Impórtala primero; será tu página raíz.
2. Las 8 páginas de dominio:
   - `01_Finanzas.md`
   - `02_Salud.md`
   - `03_Aprendizaje_IA.md`
   - `04_Productividad.md`
   - `05_Dev.md`
   - `06_Relaciones.md`
   - `07_Hobbies.md`
   - `08_Compras.md`
3. Las bases de datos CSV (impórtalas dentro de la página de dominio que corresponda):
   - `db_Ingresos.csv` y `db_Fuentes_Ingreso.csv` → dentro de **01 Finanzas**
   - `db_Gym_Log.csv` y `db_Peso_Corporal.csv` → dentro de **02 Salud**
   - `db_Aprendizaje_IA.csv` → dentro de **03 Aprendizaje IA**
   - `db_Agenda_Tareas.csv` → dentro de **04 Productividad**
   - `db_Compras_Research.csv` → dentro de **08 Compras**
4. Mueve las 8 páginas como subpáginas del HUB (arrástralas en la barra lateral) para que el índice quede limpio.

---

## 4. Ajustes post-importación (recomendado)

- En cada base de datos, cambia el tipo de columna:
  - **Importe / Peso / Horas / Reps / RPE** → tipo **Number**.
  - **Fecha** → tipo **Date**.
  - **Tipo / Estado / Sesión / Dominio** → tipo **Select** (Notion sugiere las opciones a partir de los valores existentes).
- Borra las filas marcadas con **"(ejemplo)"** cuando empieces a meter datos reales.
- En Finanzas, crea una vista filtrada por `Tipo = Recurrente` para ver de un vistazo el ingreso recurrente mensual.

---

## 5. Conectar la integración API de Notion (para que Karen escriba/lea)

Esto permite que Karen acceda al workspace vía MCP. Hazlo una sola vez:

1. Ve a **Settings → Connections** (o entra directo a `https://www.notion.so/my-integrations`).
2. Pulsa **Develop or manage integrations** → **New integration**.
3. Ponle nombre (ej. `Karen Personal`), asóciala a tu workspace y dale capacidades de **Read content**, **Update content** e **Insert content**.
4. Copia el **Internal Integration Token** (empieza por `secret_…` o `ntn_…`). **No lo compartas en público.**
5. Vuelve al workspace. En la página **HUB Karen** (y cada subpágina que quieras exponer), abre el menú `•••` → **Connections** → **Connect to** → selecciona `Karen Personal`. Compartir el HUB con la integración propaga el acceso a sus subpáginas.
6. Pásale el token a Karen (de forma privada). Karen lo guardará fuera de git.

---

## 6. Nota sobre el MCP de Notion

El servidor **MCP de Notion ya se añadió** a la config de Claude Code, pero todavía requiere:
- **Autenticar** la integración (pasos del punto 5: token + compartir páginas).
- **Reiniciar Claude Code** para que cargue el servidor MCP con el token.

Hasta que ambos pasos estén hechos, Karen no podrá leer/escribir en Notion automáticamente; el panel funcionará igual de forma manual.

---

## 7. Inventario de archivos

| Archivo | Tipo | Destino |
|---|---|---|
| `00_HUB_Karen.md` | Página | Raíz / portada |
| `01_Finanzas.md` | Página | Subpágina HUB |
| `02_Salud.md` | Página | Subpágina HUB |
| `03_Aprendizaje_IA.md` | Página | Subpágina HUB |
| `04_Productividad.md` | Página | Subpágina HUB |
| `05_Dev.md` | Página | Subpágina HUB |
| `06_Relaciones.md` | Página | Subpágina HUB |
| `07_Hobbies.md` | Página | Subpágina HUB |
| `08_Compras.md` | Página | Subpágina HUB |
| `db_Ingresos.csv` | Database | 01 Finanzas |
| `db_Fuentes_Ingreso.csv` | Database | 01 Finanzas |
| `db_Gym_Log.csv` | Database | 02 Salud |
| `db_Peso_Corporal.csv` | Database | 02 Salud |
| `db_Aprendizaje_IA.csv` | Database | 03 Aprendizaje IA |
| `db_Agenda_Tareas.csv` | Database | 04 Productividad |
| `db_Compras_Research.csv` | Database | 08 Compras |

---

*Karen Personal. Cero datos inventados: cualquier cifra en las bases viene marcada como "(ejemplo)". Bórralas antes de operar en serio.*
