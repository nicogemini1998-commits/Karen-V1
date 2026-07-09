# 🛒 Compras & Research

**Estado:** 🔵 Soporte · Research verificado antes de compras > 500 €

---

## De qué se trata

El filtro anti-compra-impulsiva. Antes de cualquier gasto **> 500 €** (hardware, herramientas, cursos, suscripciones grandes), entra en research verificado y **sparring**: Karen no te dice "cómpralo", te hace defender por qué lo necesitas, qué alternativas hay y si el dinero rinde más en otro sitio. Conecta directo con `01 Finanzas`: cada compra grande es una decisión de capital.

---

## Cómo lo construimos

- **Base de datos `db_Compras_Research`:** cada item con presupuesto, estado (Investigando / Decidido / Comprado), veredicto de Karen y links de referencia.
- **Umbral de sparring:** por debajo de 500 € decides tú; por encima, research obligatorio antes de pulsar comprar.
- **Research verificado:** comparativas multi-fuente (deep-research / firecrawl), no la primera reseña de Google.
- **Vínculo con Finanzas:** una compra grande se evalúa contra el runway y las metas; ¿acerca o aleja de los 4.500 €?

---

## Qué necesito de ti

- Abrir una **ficha en `db_Compras_Research`** antes de comprar algo > 500 €.
- El **presupuesto real** y para qué lo quieres (uso concreto, no "estaría bien tenerlo").
- Tu **deadline**: ¿es urgente o se puede esperar a una oferta / mejor momento?
- Decirme si es una compra de **inversión** (mejora ingresos/productividad) o de **consumo**.

---

## Qué esperar de Karen

- **Sparring socrático:** ¿lo necesitas o lo quieres? ¿qué problema resuelve? ¿qué pasa si no lo compras?
- **Research verificado y citado:** alternativas reales, no humo de marketing.
- **Veredicto claro** en la ficha, con el porqué (no un "sí" o "no" sin argumento).
- **Cero datos inventados:** precios y specs verificados o marcados como sin confirmar.
- **Aviso de coste de oportunidad:** qué más podrías hacer con esos > 500 €.

---

## Cómo lo mejoramos

- **Por compra:** ficha → research → veredicto → decisión → actualizar estado.
- **Aprendizaje:** revisar compras pasadas (¿acerté? ¿lo uso?) para afinar criterio futuro.
- **Lista de espera:** acumular items "deseados" y revisarlos en frío pasado un tiempo (mata muchos impulsos).
- **Norte:** que ninguna compra > 500 € se haga sin pasar por el filtro, y que cada euro grande esté justificado.
