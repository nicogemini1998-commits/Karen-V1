---
description: Conceder permiso temporal a Karen (network, write MCP, etc.). Expira por defecto end-of-session.
---

# /karen-grant

Conceder permiso temporal Karen.

## Sintaxis

```
/karen-grant <permission> --target <X> --subagent <Y> --duration <Z>
/karen-grant list
/karen-grant revoke <grant_id> | --all-active | --subagent <Y>
```

`list` y `revoke` son subcomandos del MISMO command — no existen `/karen-revoke` ni `/karen-grants` separados. Ambos operan leyendo `~/.claude/karen/grants.jsonl`.

## Permisos disponibles

| Permission | Para qué | Default expiry |
|---|---|---|
| `network` | Acceso dominio web externo | end-session |
| `write` | MCP write capability (gmail, calendar, github) | end-session |
| `bash <cmd>` | Bash comando fuera allowlist | one-shot |
| `tier-up <N>` | Tier escalation (T1→T2 etc.) | 24h max |
| `cross-domain <D1,D2>` | Cargar memoria multi-dominio | end-session |

## Ejemplos

```
/karen-grant network --target bigdata.com --subagent karen-finance --duration 1h
/karen-grant write --target gmail --subagent karen-orchestrator --duration session
/karen-grant cross-domain --target finanzas,salud --duration session
/karen-grant tier-up --target karen-learn --duration 24h
```

## Comportamiento

1. Verifica que grant pedido sea válido.
2. Si tier-up → requiere confirm humano explícito ("confirmo"):
   ```
   ⚠ GRANT TIER-UP
   Subagent: karen-learn
   Tier actual: T0 → solicitado T1
   Duración: 24h
   Trust score: 245/300 (no cumple threshold automático).

   Confirma este grant escribe `confirmo` o `cancel`.
   ```
3. Si confirmado → crea entry `~/.claude/karen/grants.jsonl`:
   ```json
   {
     "id": "grant_<uuid>",
     "granted_at": "2026-06-15T15:00:00Z",
     "expires_at": "2026-06-15T16:00:00Z",
     "permission": "network",
     "target": "bigdata.com",
     "subagent": "karen-finance",
     "granted_by": "nico-confirm",
     "reason_optional": "research uranium Q2 earnings"
   }
   ```
4. Firewall hook respeta grant durante ventana.
5. Auto-revoke al expirar.
6. Log a `01-MEMORIA/audit/grants_AAAA-MM.md`.

## Subcomando: revoke

```
/karen-grant revoke grant_<uuid>
/karen-grant revoke --all-active
/karen-grant revoke --subagent karen-finance
```

Cómo funciona (dentro del mismo command):
1. Lee `~/.claude/karen/grants.jsonl` y localiza el/los grants objetivo.
2. Append entry de revocación con `"revoked_at": "<ts ISO>"` (el log es append-only — nunca se borran líneas).
3. Firewall hook deja de respetar el grant inmediatamente.
4. Log a `01-MEMORIA/audit/grants_AAAA-MM.md`.

## Subcomando: list

```
/karen-grant list
```

Lee `~/.claude/karen/grants.jsonl` y filtra: activo = `expires_at > now` y sin `revoked_at`. No depende de ningún otro command ni servicio.

Output:
```
ACTIVE GRANTS
─────────────
grant_a1b2  network    bigdata.com    karen-finance    expires in 23min
grant_c3d4  write      gmail          karen-orchestr   expires end-session

REVOKED RECENT
─────────────
grant_e5f6  cross-domain  finanzas,dev  karen-research  revoked 2026-06-15 14:00
```

## Reglas

- **T4 grants** (privileged): siempre one-shot + audit log + nunca background.
- **Auto-expire** end-session por defecto salvo `--duration explícita`.
- **Cuento usos** por grant; alertar si grant usado >10 veces (puede indicar abuse).
- **Audit mensual** review grants pasados.
