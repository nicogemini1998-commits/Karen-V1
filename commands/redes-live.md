---
description: Lee métricas reales de tus redes (IG/TikTok) en vivo vía navegador logueado (CDP), y hace benchmarking de competencia. Resuelve el "analítica gratis = inviable".
---

# /redes-live

Lee analítica **real** de tus redes usando el navegador con tu sesión iniciada — lo que antes era inviable gratis con APIs. Para `$ARGUMENTS` (cuenta, métrica o competidor; si vacío, resumen de tus cuentas).

## Por qué funciona
La API de IG/TikTok gratis solo da datos limitados de tu propia cuenta y nada de competencia. Con el navegador **logueado** (canal CDP, ver [[capacidad-navegador-cdp]]) Karen lee lo que tú ves: tus insights reales y datos públicos de cuentas del nicho.

## Comportamiento

1. **Canal CDP.** Si `curl -s http://localhost:9222/json/version` no responde, lanzar:
   `bash 02-DEV/tooling/kanzv-browser/launch-cdp.sh "https://www.instagram.com"`
   Nico se loguea en Instagram y/o TikTok y deja las pestañas abiertas.
2. **Leer tus métricas.** Navega a Insights/Studio logueado y extrae con
   `node 02-DEV/tooling/kanzv-browser/cdp-read.mjs "<url insights>"`:
   - IG: seguidores, alcance, impresiones, engagement, rendimiento por post, mejores horas.
   - TikTok: vistas, seguidores, engagement, rendimiento por video (TikTok Analytics).
3. **Benchmarking de competencia.** Para cuentas públicas del nicho (IA/moda/couture), leer lo visible: seguidores, frecuencia, formato, hooks. Marcar claramente lo estimado vs lo medido.
4. **Volcar.** Resumen a `05-PRODUCTIVIDAD/` o al apartado Redes de Control-Day; si es decisión de estrategia, memoria + Obsidian. Conectar con [[proyecto-marca-redes]] y [[kanzv-couture-marca-pablo]].
5. **Cero datos inventados.** Si una métrica no se ve, decirlo — no rellenar.

## Límites y ética
- Solo lectura, tu propia sesión, tu contenido o datos públicos.
- Selectores de IG/TikTok cambian: si una página no parsea, leer el texto plano de la pestaña abierta (cdp-read sin URL) y extraer de ahí.
- No automatizar acciones (likes/follows/posts) sin pedírtelo explícito.

## Conexiones
- [[capacidad-navegador-cdp]]
- [[proyecto-marca-redes]]
- [[kanzv-couture-marca-pablo]]
- [[research-herramientas-redes]]
- [[_MAPA-CEREBRO]]
