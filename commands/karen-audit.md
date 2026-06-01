---
description: Audit Karen — trust scores, violations, grants, sycophancy check, memoria stale.
---

# /karen-audit

Auditoría sistema Karen completa.

## Comportamiento

Karen recopila:

1. **Trust scores** por subagent (`~/.claude/karen/trust-log.jsonl`).
2. **Violations recientes** rules-learned (severity high).
3. **Grants activos** + uso histórico.
4. **Sycophancy check:** % turnos disagreement últimos 7 días.
5. **Memoria stale:** entries `01-MEMORIA/` con `date >6m`.
6. **Tier mismatches:** subagents con score que justifica upgrade.
7. **Anti-pattern detections:** hallucinations, citations missing, raíz violations.

## Output

```
🛡️ KAREN AUDIT — 2026-06-15

TRUST SCORES
─────────────
SUBAGENT          TIER  SCORE  ÚLTIMA-VIOLACIÓN  USO-7D   STATUS
karen-orchestr    T1    580    nunca             47       ✓ healthy
karen-dev         T1    520    nunca             34       ✓ healthy
karen-finance     T2    485    2026-06-15        12       ⚠ -10 hoy
karen-health      T2    310    2026-05-30        3        ⚠ low score
karen-research    T1    640    nunca             21       ✓ healthy
karen-learn       T1    280    2026-06-10        5        ⚠ low + violación

VIOLATIONS HIGH-SEVERITY (7d)
─────────────
2026-06-15 14:32  karen-finance  sugirió compra sin sparring
2026-06-10 09:15  karen-learn    repitió pregunta ya en profile

GRANTS
─────────────
Active: 2
  - grant_a1b2  network bigdata.com  karen-finance  23min left
  - grant_c3d4  write gmail          karen-orchestr  session

Expired 7d: 8
Usage anomaly: ninguna

SYCOPHANCY CHECK
─────────────
Disagreement rate 7d: 8.4% (target >5%)  ✓ healthy
Suspicious patterns: ninguno

MEMORIA STALE
─────────────
12 entries >6 meses sin review.
Top 5:
  - 01-MEMORIA/finanzas/2025-12-research_china_etfs.md
  - 01-MEMORIA/dev/2025-11-stack-decisions.md
  - ...

Recomendación: ejecutar /karen-review-stale.

TIER UPGRADES POSIBLES
─────────────
- karen-research T1→T2: score 640 + 0 violaciones + 90d uso. ✓ elegible.
  Requiere confirm Nico para upgrade.

ANTI-PATTERNS (7d)
─────────────
- 0 hallucinations factuales detectadas
- 2 citations missing (auto-corregidas)
- 0 raíz violations (firewall bloqueó preventivo)

PRÓXIMA AUDIT
─────────────
Auto: 2026-06-22 (semanal)
Manual: cuando quieras `/karen-audit`
```

## Args opcionales

- `--detailed` muestra todo log.
- `--export` guarda JSON a `01-MEMORIA/audit/AAAA-MM-DD_audit.json`.
- `--fix` propone fixes automáticos (revoke grants raros, archive stale memory).

## Schedule

Auto cada domingo 23:00 vía Stop hook → `01-MEMORIA/audit/AAAA-MM-DD_weekly.md`.

## Alertas críticas

Karen alerta proactiva si detecta:
- Trust score subagent <100 (tier downgrade automático).
- Sycophancy rate <3% (sycophancy creeping).
- Grant usado >10 veces (puede indicar abuse).
- Violation high-severity sin captura en rule-book (hook fallando).
- Hallucination factual con citation falsa.
