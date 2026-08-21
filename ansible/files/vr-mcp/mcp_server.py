#!/usr/bin/env python3
"""Thin HTTP front for Velociraptor gRPC API — DFIR-Nexus RemoteVRMCPClient.

GET  /health  (no auth)  -> {"status":"ok","ok":true,...}
POST /vql     (Bearer)   -> {"rows":[...]}  body: {"vql": "...", "timeout_seconds": N}

Backs onto `velociraptor --api_config ... query` (gRPC :8001). Do not point
Nexus NEXUS_VR_ENDPOINT at :8001; that port is not HTTP.
"""
from __future__ import annotations

import hmac
import json
import os
import subprocess
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

BIND = os.environ.get("VR_MCP_BIND", "0.0.0.0")
PORT = int(os.environ.get("VR_MCP_PORT", "8002"))
API_KEY = os.environ.get("VR_MCP_API_KEY", "")
API_CONFIG = os.environ.get("VR_API_CONFIG", "/etc/velociraptor/api_client.yaml")
VR_BIN = os.environ.get("VR_BIN", "/usr/local/bin/velociraptor")
MAX_BODY = 1_000_000
DEFAULT_TIMEOUT = 60
MAX_TIMEOUT = 1900


def _auth_ok(handler: BaseHTTPRequestHandler) -> bool:
    if not API_KEY:
        return False
    presented = ""
    auth = handler.headers.get("Authorization", "")
    if auth.lower().startswith("bearer "):
        presented = auth[7:].strip()
    if not presented:
        presented = handler.headers.get("X-API-Key", "").strip()
    if not presented:
        return False
    return hmac.compare_digest(presented.encode("utf-8"), API_KEY.encode("utf-8"))


def _normalize_vql(vql: str) -> str:
    """Bare SELECT literals need FROM scope() on the Velociraptor API."""
    compact = " ".join(vql.split())
    if " from " not in compact.lower():
        return vql.rstrip().rstrip(";") + " FROM scope()"
    return vql


def _run_vql(vql: str, timeout: int) -> dict:
    if not os.path.isfile(API_CONFIG):
        return {"error": f"api_client config missing: {API_CONFIG}", "rows": []}
    cmd = [
        VR_BIN,
        "--api_config",
        API_CONFIG,
        "query",
        "--format",
        "jsonl",
        "--timeout",
        str(timeout),
        vql,
    ]
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout + 15,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return {"error": f"vql timed out after {timeout}s", "rows": []}
    except OSError as exc:
        return {"error": f"failed to exec velociraptor: {exc}", "rows": []}

    rows = []
    for line in (proc.stdout or "").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            rows.append(json.loads(line))
        except json.JSONDecodeError:
            rows.append({"_raw": line})

    if proc.returncode != 0 and not rows:
        err = (proc.stderr or proc.stdout or "").strip() or f"exit {proc.returncode}"
        return {"error": err, "rows": []}
    result = {"rows": rows}
    if proc.returncode != 0:
        result["warning"] = (proc.stderr or "").strip()
    return result


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt: str, *args) -> None:
        sys_stderr = __import__("sys").stderr
        sys_stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    def _send(self, code: int, payload: dict, *, extra_headers: dict | None = None) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        if extra_headers:
            for k, v in extra_headers.items():
                self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        path = urlparse(self.path).path.rstrip("/") or "/"
        if path in ("/health", "/"):
            self._send(
                200,
                {
                    "status": "ok",
                    "ok": True,
                    "service": "velociraptor-mcp",
                    "api_config": os.path.isfile(API_CONFIG),
                },
            )
            return
        self._send(404, {"ok": False, "error": "not found"})

    def do_POST(self) -> None:
        path = urlparse(self.path).path.rstrip("/") or "/"
        if path not in ("/vql", "/api/vql"):
            self._send(404, {"ok": False, "error": "not found"})
            return
        if not _auth_ok(self):
            self._send(401, {"ok": False, "error": "unauthorized"})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self._send(400, {"ok": False, "error": "bad content-length"})
            return
        if length > MAX_BODY:
            self._send(413, {"ok": False, "error": "body too large"})
            return
        raw = self.rfile.read(length) if length else b"{}"
        try:
            data = json.loads(raw.decode("utf-8") or "{}")
        except (json.JSONDecodeError, UnicodeDecodeError):
            self._send(400, {"ok": False, "error": "invalid json"})
            return
        vql = (data.get("vql") or "").strip()
        if not vql:
            self._send(400, {"ok": False, "error": "missing vql"})
            return
        try:
            timeout = int(data.get("timeout_seconds") or DEFAULT_TIMEOUT)
        except (TypeError, ValueError):
            timeout = DEFAULT_TIMEOUT
        timeout = max(5, min(timeout, MAX_TIMEOUT))
        try:
            result = _run_vql(_normalize_vql(vql), timeout)
        except Exception as exc:  # noqa: BLE001 — return JSON, never crash the worker
            result = {"error": str(exc), "rows": [], "trace": traceback.format_exc()}
        code = 200 if "error" not in result else 502
        self._send(code, result)


def main() -> None:
    if not API_KEY:
        raise SystemExit("VR_MCP_API_KEY is required")
    httpd = ThreadingHTTPServer((BIND, PORT), Handler)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
