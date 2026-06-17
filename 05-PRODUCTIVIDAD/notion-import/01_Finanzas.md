# 💰 Finanzas & Ingresos

**Estado:** 🟢 Meta norte 2026 · Objetivo: ingresos recurrentes > 4.500 €/mes

---

## De qué se trata

El centro económico de Nico. Aquí se traza y se ejecuta el camino hasta superar los **4.500 €/mes de forma recurrente** (no puntual). El motor tiene tres palancas: ingresos por servicios IA/dev, productos propios, e inversión que pone el capital a trabajar. Karen actúa como **sparring socrático**: nunca dice "compra X" ni "invierte en Y"; te hace las preguntas que te obligan a defender la tesis antes de mover dinero.

---

## Cómo lo construimos

- **Dos bases de datos núcleo:**
  - `db_Ingresos` — cada euro que entra, mes a mes, con tipo (recurrente/puntual) y fuente.
  - `db_Fuentes_Ingreso` — el inventario de motores: cuáles están activos, pausados o en prospecto, y cuánto aporta cada uno.
- **Métrica única de verdad:** suma de ingresos **recurrentes** del mes. Esa es la cifra que persigue la meta, no los picos puntuales.
- **Vista mensual:** agrupar `db_Ingresos` por mes y ver la curva hacia los 4.500 €.
- **Separar señal de ruido:** un proyecto puntual de 2.000 € es caja, pero no mueve la aguja de la meta recurrente. Marcarlo bien.

---

## Qué necesito de ti

- Registrar **cada ingreso** cuando entra (no acumular y olvidar). Fuente, importe neto, recurrente o puntual.
- Definir tus **fuentes activas hoy** en `db_Fuentes_Ingreso` (aunque sea 0 € de momento).
- Decir tu **runway**: cuántos meses aguantas con gastos actuales si los ingresos caen a cero. (No me lo invento.)
- Avisarme antes de cualquier **decisión financiera > 500 €** o cualquier movimiento de inversión.

---

## Qué esperar de Karen

- **Sparring socrático siempre.** Pregunto: ¿cuál es la tesis? ¿qué tiene que pasar para que esto falle? ¿cuál es el coste de oportunidad?
- **Cero cifras inventadas.** Si no tengo el dato real, lo digo, no lo relleno.
- **Cálculo de la brecha:** cuánto te falta cada mes para los 4.500 € y qué fuente puede cerrarla más rápido.
- **Alertas de concentración:** si el 80 % del ingreso viene de una sola fuente, te lo señalo como riesgo.
- **Research verificado** (vía deep-research / bigdata) cuando evalúes una inversión o un producto financiero.

---

## Cómo lo mejoramos

- **Mes 1–2:** registro disciplinado + foto real de fuentes. Saber de dónde sale cada euro hoy.
- **Mes 3–4:** identificar la fuente con mejor ratio esfuerzo/recurrencia y doblar apuesta ahí.
- **Trimestral:** revisar mix de ingresos (servicio vs. producto vs. inversión) y reducir dependencia de una sola.
- **Automatizar:** que Karen lea ingresos vía MCP y calcule la brecha sin que tengas que sumar a mano.
- **Norte:** que el ingreso recurrente cruce 4.500 € y se mantenga 3 meses seguidos antes de cantar victoria.
