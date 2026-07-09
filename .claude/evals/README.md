# Eval-Driven Development — Karen

Framework de evaluación basado en ECC Eval Harness.

## Filosofía
Define criterios de ÉXITO antes de escribir una línea de código.
Los evals son los "unit tests del desarrollo con IA".

## Tipos de eval

### Capability eval — feature nueva
```markdown
[CAPABILITY EVAL: nombre-feature]
Task: descripción exacta de qué debe lograr
Success Criteria:
  - [ ] criterio 1 (verificable)
  - [ ] criterio 2
  - [ ] criterio 3
Grader: bash | claude | manual
Expected Output: descripción del resultado esperado
```

### Regression eval — no romper lo que funciona
```markdown
[REGRESSION EVAL: nombre-area]
Baseline: sha-commit o checkpoint-nombre
Tests:
  - test-1: PASS/FAIL
  - test-2: PASS/FAIL
Result: X/Y passed (previously Y/Y)
```

## Métricas
- **pass@k:** al menos 1 de k intentos exitoso → confiabilidad básica
- **pass^k:** todos k exitosos → confiabilidad alta (producción)

## Graders disponibles

### Code-based (determinista)
```bash
# Verificar que X existe
grep -q "expected-string" src/file.ts && echo "PASS" || echo "FAIL"

# Verificar que tests pasan
npm test -- --testPathPattern="feature" && echo "PASS" || echo "FAIL"

# Verificar build
npm run build && echo "PASS" || echo "FAIL"
```

### Model-based (Claude evalúa)
Prompt: "Evalúa si este código cumple [criterio]. Responde PASS o FAIL con razón."

## Archivos en este directorio
- `baseline.json` — snapshot de referencia
- `<feature>.md` — criterios de aceptación
- `<feature>.log` — resultados de ejecución
