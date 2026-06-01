"""
Karen — cost_optimizer.py
=========================
Abaratar costes Claude API + Claude Code.

Estrategias 2026:
1. Prompt caching (5min default, 1h beta) — 90% cost reduction reads cacheados.
2. Model routing — Haiku 4.5 ($1/$5 1M tok) para tareas baratas, Opus 4.7 ($15/$75) crítico.
3. Convert PDFs/docs grandes → Markdown (10x menos tokens).
4. Memoria persistente para evitar re-leer (Mem0 + profile.json).
5. Token budget hard caps por sesión.
6. Subagents con context isolation (no heredan main context = ahorro).
"""

import json
import re
import sys
from pathlib import Path
from typing import Optional


# Tarifas 2026 (cents per million tokens — actualizar con cada release)
MODELS = {
    "haiku-4-5":    {"input": 100,  "output": 500,  "cached_read": 10,   "best_for": "extraction|classification|simple-edit"},
    "sonnet-4-6":   {"input": 300,  "output": 1500, "cached_read": 30,   "best_for": "code|review|research-medium"},
    "opus-4-7":     {"input": 1500, "output": 7500, "cached_read": 150,  "best_for": "deep-reasoning|critical-decision|sparring"},
    "opus-4-8":     {"input": 1500, "output": 7500, "cached_read": 150,  "best_for": "newest|highest-capability"},
}


# Routing rules por tarea
TASK_TO_MODEL = {
    # Haiku — tareas simples
    "extract_entities": "haiku-4-5",
    "classify_email": "haiku-4-5",
    "summarize_short": "haiku-4-5",
    "rule_extraction": "haiku-4-5",
    "format_conversion": "haiku-4-5",
    "memory_filter_judge": "haiku-4-5",
    "ocr": "haiku-4-5",
    "tag_generation": "haiku-4-5",

    # Sonnet — coding + research medium
    "code_write": "sonnet-4-6",
    "code_review": "sonnet-4-6",
    "research_medium": "sonnet-4-6",
    "morning_brief": "sonnet-4-6",
    "doc_writing": "sonnet-4-6",
    "test_generation": "sonnet-4-6",

    # Opus — crítico
    "architecture_decision": "opus-4-7",
    "deep_research": "opus-4-7",
    "sparring_finance": "opus-4-7",
    "sparring_health": "opus-4-7",
    "complex_refactor": "opus-4-7",
    "security_audit": "opus-4-7",
}


def estimate_cost(input_tokens: int, output_tokens: int, model: str, cached_tokens: int = 0) -> float:
    """Estima coste USD para una llamada."""
    if model not in MODELS:
        return 0.0
    m = MODELS[model]
    cost_cents = (
        (input_tokens - cached_tokens) * m["input"] / 1_000_000
        + cached_tokens * m["cached_read"] / 1_000_000
        + output_tokens * m["output"] / 1_000_000
    )
    return cost_cents / 100


def recommend_model(task: str, context_size_tokens: int = 0, criticality: str = "normal") -> str:
    """
    Recomienda modelo óptimo.

    Args:
        task: nombre tarea (ver TASK_TO_MODEL).
        context_size_tokens: tokens de context (Opus >100k justificable).
        criticality: "trivial" | "normal" | "critical".
    """
    # Lookup directo
    if task in TASK_TO_MODEL:
        return TASK_TO_MODEL[task]

    # Por criticalidad
    if criticality == "critical":
        return "opus-4-7"
    if criticality == "trivial":
        return "haiku-4-5"

    # Por context size
    if context_size_tokens > 100_000:
        return "opus-4-7"  # Solo Opus maneja bien >100k
    if context_size_tokens > 30_000:
        return "sonnet-4-6"

    return "haiku-4-5"  # default barato


def cache_eligible(content: str, min_tokens: int = 1024) -> bool:
    """
    Determina si content es elegible para prompt caching.

    Reglas Anthropic 2026:
    - Mínimo 1024 tokens (1024 = Sonnet/Opus, 2048 = Haiku).
    - Caching útil si reusado >2 veces en 5min.
    - Cache hit = 10% del precio normal lectura.
    """
    # Estimación ratio tokens (1 token ≈ 4 chars EN, ≈ 3 chars ES)
    estimated_tokens = len(content) / 3.5
    return estimated_tokens >= min_tokens


def should_use_memory_instead(query: str, context_summary: str = "") -> tuple[bool, str]:
    """
    Decide si query puede responderse con memoria existente vs reprocesar.

    Returns:
        (True, "use_memory") si memoria probable tiene respuesta.
        (False, "need_fresh") si necesita context fresco.
    """
    memory_hints = [
        r"\b(qué|cuál|cómo|dónde)[^?]*\bmi(s)?\b",                      # "¿qué broker es mi favorito?"
        r"\bmi(s)?\s+(broker|stack|preferencia|estilo|tono|favorito|configuración|setup)",  # "mi broker actual"
        r"\b(recuerdas?|sabías?|conoces?)\b",
        r"\b(según|basado en)\s+(la|mi|nuestra)\s+memoria\b",
        r"^/memoria|^/recall|^/mem-search",
        r"\b(qué|cuál) (es|son|tengo|prefiero|uso)\b.*\?",
    ]

    for pattern in memory_hints:
        if re.search(pattern, query, re.IGNORECASE):
            return True, f"matched_memory_hint: {pattern}"

    return False, "treat_as_fresh"


def doc_to_markdown_cost_estimate(file_path: str, file_size_mb: float) -> dict:
    """
    Estima ahorro convirtiendo PDF/docx → Markdown.

    PDF/docx: ~3-5x más tokens que markdown equivalente
    (binary + estructura + metadata).
    """
    ext = file_path.lower().split(".")[-1]
    multipliers = {
        "pdf": 4.0,
        "docx": 3.5,
        "doc": 3.5,
        "pptx": 5.0,
        "xlsx": 4.5,
        "html": 2.0,
    }
    mult = multipliers.get(ext, 1.0)

    # ~1MB ≈ 250k tokens raw
    raw_tokens = int(file_size_mb * 250_000 * mult)
    md_tokens = int(file_size_mb * 250_000)

    cost_raw_sonnet = estimate_cost(raw_tokens, 0, "sonnet-4-6")
    cost_md_sonnet = estimate_cost(md_tokens, 0, "sonnet-4-6")

    return {
        "raw_tokens": raw_tokens,
        "md_tokens": md_tokens,
        "savings_pct": round((1 - md_tokens / raw_tokens) * 100, 1),
        "cost_raw_sonnet_usd": round(cost_raw_sonnet, 4),
        "cost_md_sonnet_usd": round(cost_md_sonnet, 4),
        "savings_usd": round(cost_raw_sonnet - cost_md_sonnet, 4),
        "recommendation": f"Convertir {file_path} a markdown ahorra ~{round((1 - md_tokens / raw_tokens) * 100)}%",
    }


# ────────────────────────────────────────────────────────────
# Session budget tracking
# ────────────────────────────────────────────────────────────
class SessionBudget:
    """Tracking + hard cap por sesión Karen."""

    def __init__(self, max_usd: float = 5.0, log_path: Optional[Path] = None):
        self.max_usd = max_usd
        self.spent_usd = 0.0
        self.calls = 0
        self.log_path = log_path or (Path.home() / ".claude" / "karen" / "cost-log.jsonl")
        self.log_path.parent.mkdir(parents=True, exist_ok=True)

    def add_call(self, model: str, input_tokens: int, output_tokens: int, cached: int = 0):
        cost = estimate_cost(input_tokens, output_tokens, model, cached)
        self.spent_usd += cost
        self.calls += 1

        from datetime import datetime, timezone
        ts = datetime.now(timezone.utc).isoformat()
        entry = {
            "ts": ts,
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cached_tokens": cached,
            "cost_usd": cost,
            "session_total_usd": self.spent_usd,
        }
        with self.log_path.open("a") as f:
            f.write(json.dumps(entry) + "\n")

        return cost, self.over_budget()

    def over_budget(self) -> bool:
        return self.spent_usd >= self.max_usd

    def remaining(self) -> float:
        return max(0, self.max_usd - self.spent_usd)


# ────────────────────────────────────────────────────────────
# Test
# ────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== Routing recommendations ===")
    print(f"  extract_entities: {recommend_model('extract_entities')}")
    print(f"  sparring_finance: {recommend_model('sparring_finance')}")
    print(f"  unknown task with critical: {recommend_model('foo', criticality='critical')}")

    print("\n=== Cost estimates ===")
    print(f"  1k in + 500 out Haiku: ${estimate_cost(1000, 500, 'haiku-4-5'):.5f}")
    print(f"  1k in + 500 out Sonnet: ${estimate_cost(1000, 500, 'sonnet-4-6'):.5f}")
    print(f"  1k in + 500 out Opus: ${estimate_cost(1000, 500, 'opus-4-7'):.5f}")
    print(f"  Sonnet con 80% cached: ${estimate_cost(10000, 1000, 'sonnet-4-6', cached_tokens=8000):.5f}")

    print("\n=== Doc conversion savings ===")
    print(doc_to_markdown_cost_estimate("manual.pdf", 2.5))

    print("\n=== Memory routing ===")
    print(should_use_memory_instead("¿Qué broker es mi favorito?"))
    print(should_use_memory_instead("Refactor src/auth.ts"))
