---
description: Backup completo de ~/.claude/karen/ a tar.gz timestamped. List + restore por fecha. Retención 10.
---

# /karen-backup

Backup del estado completo Karen (`~/.claude/karen/`: profile, grants, trust-log, audit-log, rules-learned, firewall, integrity ledger).

## Sintaxis

```
/karen-backup --now              # crea backup ahora (default si no hay args)
/karen-backup --list             # lista backups disponibles
/karen-backup --restore <fecha>  # restaura un backup (AAAA-MM-DD o nombre exacto)
```

## Comportamiento

### `--now` (default)

1. `tar.gz` de `~/.claude/karen/` **excluyendo** `backups/` (no backups de backups):
   ```bash
   tar --exclude='backups' -czf \
     ~/.claude/karen/backups/karen-$(date +%Y-%m-%d_%H%M%S).tar.gz \
     -C ~/.claude karen
   ```
2. **Retención 10:** si hay >10 tar.gz, borra los más antiguos hasta quedar 10. Los directorios por sesión de `/verify-integrity` no cuentan ni se tocan.
3. Confirma: nombre, tamaño, total de backups.

```
💾 KAREN BACKUP
────────
✓ Creado: backups/karen-2026-06-15_221045.tar.gz (1.2 MB)
✓ Retención: 7/10 backups (ninguno borrado)
```

### `--list`

```
💾 BACKUPS DISPONIBLES (7/10)
────────
karen-2026-06-15_221045.tar.gz   1.2 MB   hace 2min
karen-2026-06-14_080012.tar.gz   1.2 MB   hace 1d
karen-2026-06-08_193027.tar.gz   1.1 MB   hace 7d
...
```

### `--restore <fecha>`

1. Localiza el tar.gz por fecha (`AAAA-MM-DD` → el más reciente de ese día) o por nombre exacto.
2. **Safety primero:** crea backup del estado ACTUAL (`karen-<ts>-pre-restore.tar.gz`) — restore nunca destruye sin red.
3. Muestra qué va a sobrescribir y **espera confirm explícito** ("confirmo").
4. Extrae sobre `~/.claude/karen/` (sin tocar `backups/`).
5. Recomienda `/verify-integrity check` inmediato (el ledger pre-restore ya no aplica).

## Cuándo correrlo

- Manual antes de tocar hooks, firewall o `profile.json` a mano.
- `/verify-integrity` ya hace snapshot por SessionStart; esto es el punto de restauración **explícito y portable** (un solo archivo, se puede copiar fuera de la máquina).

## Reglas

- El tar.gz contiene secretos de configuración → se queda en local. NUNCA al repo, NUNCA a cloud sync (misma regla que `settings.local.json`).
- Restore sin confirm explícito = prohibido.
- Si `backups/` no existe (install incompleto) → crearla y avisar.
