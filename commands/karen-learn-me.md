---
description: Active-learning onboarding. Karen aprende sobre Nico con preguntas de alta entropía. Máximo 5 por sesión.
---

# /karen-learn-me

Onboarding activo. Karen identifica lo que NO sabe + pregunta solo lo que aporta más info por pregunta.

## Comportamiento

### Fase 1 — Auditoría memoria actual

Karen escanea:
- `~/.claude/karen/profile.json`
- `01-MEMORIA/<dominios>/`
- Graphiti graph entities

Identifica **gaps de alta entropía** (lo que NO sabe + impacta workflow).

### Qué cuenta como "gap crítico" (métrica concreta, no vibes)

Un gap es **crítico** si cumple cualquiera de estas dos condiciones medibles:

1. **Entidad mencionada >2x sin memoria** — Nico nombró algo (broker, proyecto, persona, herramienta) más de 2 veces y NO existe entrada en `01-MEMORIA/` ni entity en el graph. Karen habla de ello a ciegas cada vez.
2. **Campo `profile.json` undefined** — un campo que algún command necesita (`topics_watch`, broker, scopes, tabúes) está vacío o ausente. Ej.: `/morning-brief` sin `topics_watch` = research genérico inútil.

Todo lo demás es gap "nice-to-have" — solo entra en las 5 preguntas si no quedan críticos pendientes.

### Fase 2 — Selección preguntas

Quote SOTA: *"Active Learning is employed to address the cold-start problem … to maximize information acquisition with minimal user effort by selecting informative data."*

Karen selecciona MÁXIMO 5 preguntas, ordenadas por impacto:

```
🧠 KAREN LEARN — 5 preguntas alta-impacto

1. **Broker actual:** ¿Trade Republic confirmado o cambiaste?
   (Impact: bloquea todo sparring finanzas con info actualizada)

2. **GitHub token scope:** ¿`repo` + `read:user`? ¿Necesitas más?
   (Impact: gated MCP github operaciones)

3. **Tópicos watch finanzas:** ¿Qué tickers/sectores monitorizo en morning-brief?
   (Impact: digest matutino personalizado)

4. **Notion workspace:** ¿URL workspace personal cuando esté listo?
   (Impact: sync productividad)

5. **Tabúes/temas off-limits:** ¿Algo NO quieres que Karen toque?
   (Impact: privacy boundaries)

Responde 1 por 1 o todas juntas. Skip cualquiera con `/`.
```

### Fase 3 — Almacenamiento

Cada respuesta → upsert a:
- `profile.json` si es preference estable.
- `01-MEMORIA/<dominio>/PROFILE_<topic>.md` si es contexto profundo.
- Graphiti entity + relation si es relación con entidad.

### Fase 4 — Confirmación

```
✅ KAREN LEARN — sesión completada

Aprendí:
- Broker: <X> (confirmed)
- GitHub scope: <Y>
- Tópicos watch: <list>
- Notion: <Z>
- Tabúes: <ninguno/lista>

Profile actualizado: ~/.claude/karen/profile.json
Memoria upsert: <N> entradas
Graphiti: <M> entities, <K> relations

Próximo learn: en 30 días o cuando detecte gap relevante.
```

## Reglas

- **MÁXIMO 5 preguntas** por sesión `/karen-learn-me`. No interrogar.
- **Skip permitido:** Nico puede pasar pregunta con `/` o "skip".
- **Alta entropía:** Karen solo pregunta lo que aporta mucha info. No "¿cuál es tu color favorito?" salvo aplicable.
- **No re-preguntar** lo ya en memoria salvo Karen detecte stale (>6 meses).

## Auto-trigger

Karen puede auto-invocar `/karen-learn-me` si:
- Detecta 3+ gaps críticos en sesión actual.
- Memoria stale severity > umbral.
- Nuevo dominio activado.

En esos casos: "Detecté gaps importantes. ¿Te pregunto 3 cosas rápidas? `/karen-learn-me`".

## Ejemplo flow

```
Nico: /karen-learn-me

Karen:
🧠 5 preguntas alta-impacto:

1. ¿Broker actual confirmado?
2. ¿GitHub token scope?
3. ¿Tópicos watch finanzas?
4. ¿Notion URL?
5. ¿Tabúes?

Nico: 1. trade republic, 2. repo solo, 3. uranium AI semis, 4. /, 5. nada

Karen:
✅ Aprendí 4/5. Skipped Notion (entiendo, cuando esté listo).

profile.json actualizado.
4 entries upsert Mem0.

¿Activo morning-brief con tópicos watch?
```

## Privacidad

- Respuestas T2 (finanzas/salud/relaciones) van a `01-MEMORIA/<dominio>/` gitignored.
- Respuestas generales van a `profile.json` local.
- Nada al repo público.

## Conexiones

- [[Quién es Nico]]
- [[PERFIL_NICO]]
- [[Memoria por dominios]]
- [[learn-tutor]]
- [[_MAPA-CEREBRO]]
