---
description: Verifica integridad config Karen (hooks, settings, agents). Detecta tampering. Restaurar de backup si comprometido.
---

# /verify-integrity

Verifica + restaura integridad Karen.

## Args

- `check` (default) — verifica hash ledger sin actuar.
- `accept` — acepta drift como legítimo, actualiza ledger.
- `restore` — restaura desde último backup conocido bueno.
- `mcp` — verifica MCP server pins.
- `full` — todo lo anterior.

## Comportamiento

1. Lee `~/.claude/karen/integrity/ledger.sha256`.
2. Recalcula hash sobre archivos críticos:
   - `~/.claude/settings.json`
   - `~/.claude/.mcp.json`
   - `~/.claude/hooks/`
   - `~/.claude/karen/hooks/`
   - `~/.claude/agents/`
   - `~/.claude/karen/firewall/`
   - `~/.claude/CLAUDE.md`
3. Compara.

### Si match → OK
```
✓ Integridad verificada.
Hash actual: <sha256>
Ledger:      <sha256>
Última verificación: <ts>
```

### Si drift → ALERT
```
⚠ INTEGRIDAD COMPROMETIDA

Hash actual: <sha256>
Ledger:      <sha256>

Diff archivos modificados:
  ~/.claude/settings.json    modified 2026-06-15T14:32
  ~/.claude/hooks/auto-foo.sh   created 2026-06-15T14:33  ⚠ DESCONOCIDO

Acciones:
  1. /verify-integrity accept   ← si reconoces cambios
  2. /verify-integrity restore  ← si NO reconoces (posible compromise)
  3. Inspecciona manualmente antes de decidir.
```

## Restore desde backup

Backup automático cada SessionStart en `~/.claude/karen/backups/AAAA-MM-DD/`.

`restore` copia último backup → restaura state limpio.

## MCP verification

`/verify-integrity mcp`:
- Re-checkea `npm view <pkg> dist.integrity` vs `mcp-pins.txt`.
- Si drift → alerta posible rug-pull.
- Acción Nico: review `git log` paquete + decidir accept o rollback.

## Forensics

Si compromise detectado:
1. Karen pausa cualquier tool use.
2. Genera report `~/.claude/karen/integrity/incident-AAAA-MM-DDTHHMMSS.md`.
3. Lista: archivos modificados, timestamps, hashes, hooks rotos.
4. Sugiere: `git diff` settings.json, review hooks recientes.
5. Si Nico confirma rollback → restore + revoke OAuth tokens preventivo.

## Output ejemplo

```
🛡️ KAREN INTEGRITY CHECK

Archivos críticos:           7
Hash ledger vs actual:       ✓ MATCH
MCP pins vs npm registry:    ✓ 5/5 verified
Hooks executable bit:        ✓ todos 100755
Settings.json validez JSON:  ✓ parseable
Subagents config:            ✓ 6/6 válidos

Última manipulación detectada:  ninguna en 30d

Status: ✅ INTEGRIDAD OK
```

## Conexiones

- [[THREAT-MODEL]]
- [[verify-creds]]
- [[karen-audit]]
- [[Reglas operativas]]
- [[_MAPA-CEREBRO]]
