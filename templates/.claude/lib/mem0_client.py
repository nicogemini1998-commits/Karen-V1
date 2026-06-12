#!/usr/bin/env python3
"""
Karen — mem0_client.py
======================
Cliente liviano (stdlib puro, cero deps) para el server Mem0 self-hosted
de templates/docker-compose.memory.yml (karen-mem0 en 127.0.0.1:8888).

Endpoints reales del server inline:
    POST   /add                  {text, user_id, metadata}
    POST   /search               {query, user_id, limit, filter}
    DELETE /memories/{memory_id}
    GET    /health

Uso como librería:
    from mem0_client import add, search, delete, health
    add("Nico prefiere Trade Republic", domain="finanzas")
    search("broker", domain="finanzas", limit=5)

Uso CLI:
    python3 mem0_client.py health
    python3 mem0_client.py add --domain finanzas "Nico prefiere Trade Republic"
    python3 mem0_client.py search --domain finanzas --limit 5 "broker"
    python3 mem0_client.py delete <memory_id>
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from typing import Any

BASE_URL: str = os.environ.get("MEM0_BASE_URL", "http://127.0.0.1:8888")
DEFAULT_USER_ID: str = os.environ.get("MEM0_USER_ID", "nico")
REQUEST_TIMEOUT_S: int = 30
STACK_DOWN_MSG: str = (
    "Stack memoria no levantado — "
    "cd 10-GRAPHIFY && docker compose -f docker-compose.memory.yml up -d"
)


class Mem0Error(RuntimeError):
    """Error genérico hablando con el server Mem0."""


class Mem0ConnectionError(Mem0Error):
    """El server no responde (connection refused / timeout / DNS)."""


def _request(method: str, path: str, payload: dict[str, Any] | None = None) -> Any:
    """HTTP request mínimo vía urllib. Devuelve el JSON decodificado."""
    url = f"{BASE_URL}{path}"
    data = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urllib.request.Request(
        url, data=data, method=method, headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req, timeout=REQUEST_TIMEOUT_S) as resp:
            body = resp.read().decode("utf-8")
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")[:300]
        raise Mem0Error(f"HTTP {exc.code} en {method} {path}: {detail}") from exc
    except (urllib.error.URLError, ConnectionError, TimeoutError, OSError) as exc:
        raise Mem0ConnectionError(STACK_DOWN_MSG) from exc


def add(
    text: str,
    domain: str,
    metadata: dict[str, Any] | None = None,
    user_id: str = DEFAULT_USER_ID,
) -> Any:
    """Guarda una memoria. `domain` va siempre en metadata (aislamiento por dominio)."""
    if not text.strip():
        raise ValueError("text vacío — nada que guardar")
    if not domain.strip():
        raise ValueError("domain obligatorio (ej. finanzas, dev, salud)")
    merged = {"domain": domain, **(metadata or {})}
    payload = {"text": text, "user_id": user_id, "metadata": merged}
    return _request("POST", "/add", payload)


def search(
    query: str,
    domain: str | None = None,
    limit: int = 5,
    user_id: str = DEFAULT_USER_ID,
) -> Any:
    """Búsqueda semántica. Con `domain` filtra por metadata.domain (regla aislamiento)."""
    if not query.strip():
        raise ValueError("query vacía")
    payload = {
        "query": query,
        "user_id": user_id,
        "limit": limit,
        "filter": {"domain": domain} if domain else {},
    }
    return _request("POST", "/search", payload)


def delete(memory_id: str) -> Any:
    """Borra una memoria por id (DELETE /memories/{id})."""
    if not memory_id.strip():
        raise ValueError("memory_id vacío")
    return _request("DELETE", f"/memories/{memory_id}")


def health() -> Any:
    """Ping al server. Lanza Mem0ConnectionError si el stack no está levantado."""
    return _request("GET", "/health")


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="mem0_client.py", description="Cliente CLI para el stack memoria Karen (Mem0)"
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_add = sub.add_parser("add", help="guardar memoria")
    p_add.add_argument("text", help="texto a memorizar")
    p_add.add_argument("--domain", required=True, help="dominio (finanzas, dev, salud...)")
    p_add.add_argument("--metadata", default=None, help='JSON extra, ej. \'{"type":"decision"}\'')

    p_search = sub.add_parser("search", help="búsqueda semántica")
    p_search.add_argument("query", help="qué buscar")
    p_search.add_argument("--domain", default=None, help="filtrar por dominio")
    p_search.add_argument("--limit", type=int, default=5)

    p_del = sub.add_parser("delete", help="borrar memoria por id")
    p_del.add_argument("memory_id")

    sub.add_parser("health", help="comprobar que el server responde")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        if args.cmd == "add":
            extra = json.loads(args.metadata) if args.metadata else None
            result = add(args.text, domain=args.domain, metadata=extra)
        elif args.cmd == "search":
            result = search(args.query, domain=args.domain, limit=args.limit)
        elif args.cmd == "delete":
            result = delete(args.memory_id)
        else:
            result = health()
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return 0
    except Mem0ConnectionError as exc:
        print(f"✗ {exc}", file=sys.stderr)
        return 2
    except (Mem0Error, ValueError, json.JSONDecodeError) as exc:
        print(f"✗ {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
