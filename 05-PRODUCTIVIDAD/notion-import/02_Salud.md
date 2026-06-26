# 💪 Salud & Fitness

**Estado:** 🟢 Meta norte 2026 · Objetivo: subir masa muscular y marcar (lean bulk)

> ⚠️ Karen no es médico. Lo de aquí es seguimiento y motivación, no consejo clínico. Para temas de salud serios, profesional sanitario.

---

## De qué se trata

El cuerpo es la base de energía de todo el sistema. Sin él, ni finanzas ni IA rinden. El objetivo es **lean bulk**: subir masa muscular minimizando grasa, con gym constante y nutrición controlada, hasta verte marcado. No es estética por estética: es disciplina entrenable que se transfiere al resto de dominios.

---

## Cómo lo construimos

- **Dos bases de datos:**
  - `db_Gym_Log` — cada sesión, ejercicio a ejercicio: peso, reps, RPE. Permite ver progresión de carga.
  - `db_Peso_Corporal` — peso corporal en el tiempo, para vigilar que el bulk sea *lean* y no descontrolado.
- **Estructura de entreno:** split tipo Push / Pull / Legs (o Upper / Lower) registrado por sesión.
- **Sobrecarga progresiva** como motor: el log existe para que cada semana intentes batir el peso o las reps del ejercicio clave.
- **Tendencia de peso, no báscula diaria:** mirar la media semanal, no el ruido del día a día.

---

## Qué necesito de ti

- **Loguear cada sesión** (aunque sea rápido): los ejercicios principales con peso y reps. El resto se puede estimar.
- **Pesarte con consistencia** (mismo momento del día, ej. en ayunas) y anotarlo en `db_Peso_Corporal`.
- Decirme tu **objetivo de superávit** y tu peso de partida real (no me lo invento).
- Avisar de lesiones, molestias o semanas de descarga para no empujar carga a ciegas.

---

## Qué esperar de Karen

- **Motivación constante** sin paternalismo: te recuerdo la racha y te pico cuando aflojas.
- **Lectura de progresión:** te señalo si un ejercicio está estancado varias semanas y toca cambiar algo.
- **Cruce peso vs. fuerza:** si el peso sube pero la fuerza no, aviso de que puede ser grasa, no músculo.
- **Cero datos inventados:** si no logueaste, no relleno la sesión.
- **Disclaimer activo:** en cualquier duda médica te derivo a un profesional.

---

## Cómo lo mejoramos

- **Semana 1:** definir split y registrar línea base de peso + cargas iniciales.
- **Cada 4 semanas:** revisar progresión de los 3-4 ejercicios principales y ajustar.
- **Cada 8–12 semanas:** decidir si seguir en bulk o entrar en mini-cut según evolución de peso/definición.
- **Integrar nutrición:** añadir registro de calorías/proteína cuando estés listo para ese nivel de detalle.
- **Automatizar:** que Karen lea el log y te genere el resumen semanal de progresión sin pedirlo.
