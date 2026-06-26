#!/usr/bin/env bash
# Hook PostToolUse — typecheck automático del dashboard Next.js.
# Solo actúa si se editó un archivo bajo el src/ del proyecto. Atrapa errores TS
# antes de que lleguen a runtime (mejora del informe de uso). Silencioso si todo OK.

input=$(cat)
f=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

case "$f" in
  */02-DEV/proyectos-activos/control-day/src/*)
    proj="/Users/nicoopenclow/Desktop/karen asistente/02-DEV/proyectos-activos/control-day"
    cd "$proj" 2>/dev/null || exit 0
    command -v pnpm >/dev/null 2>&1 || exit 0
    if ! out=$(pnpm exec tsc --noEmit 2>&1); then
      printf '⚠️ TypeScript (control-day) reporta errores tras editar %s:\n%s\n' "$f" "$(printf '%s' "$out" | tail -15)" >&2
      exit 2
    fi
    ;;
esac
exit 0
