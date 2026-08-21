#!/usr/bin/env python3
"""Rollover logs-* data streams and delete old backing indices. Keeps streams/Fleet."""
from __future__ import annotations

import base64
import json
import sys
import urllib.error
import urllib.request


def call(auth: str, method: str, path: str, timeout: int = 180) -> dict:
    req = urllib.request.Request(f"http://127.0.0.1:9200{path}", method=method)
    req.add_header("Authorization", f"Basic {auth}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = (resp.read().decode() or "{}").strip()
            if raw.startswith("{") or raw.startswith("["):
                return json.loads(raw)
            return {"raw": raw}
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"HTTP {e.code} {method} {path}: {err[:400]}")
        return {"error": True, "code": e.code}
    except Exception as e:  # noqa: BLE001 — ops script, report and continue
        print(f"ERR {method} {path}: {e}")
        return {"error": True}


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: lab-log-reset-es.py <elastic-password>", file=sys.stderr)
        return 2
    auth = base64.b64encode(f"elastic:{sys.argv[1]}".encode()).decode()

    cancel = call(auth, "POST", "/_tasks/_cancel?actions=*byquery")
    print(f"CANCEL_BYQUERY node_failures={cancel.get('node_failures')}")

    ds = call(auth, "GET", "/_data_stream/logs-*")
    streams = ds.get("data_streams") or []
    if not streams:
        print("NO_LOGS_DATA_STREAMS")
        return 0

    old: list[str] = []
    for stream in streams:
        name = stream["name"]
        for idx in stream.get("indices") or []:
            iname = idx.get("index_name") or idx.get("index")
            if iname:
                old.append(iname)
        rol = call(auth, "POST", f"/{name}/_rollover")
        print(f"ROLLOVER {name} ack={rol.get('acknowledged')} new={rol.get('new_index')}")

    old = sorted(set(old))
    print(f"OLD_BACKING {len(old)}")
    for i in range(0, len(old), 15):
        batch = ",".join(old[i : i + 15])
        r = call(auth, "DELETE", f"/{batch}?ignore_unavailable=true")
        print(f"DELETE_BATCH {i} ack={r.get('acknowledged')} err={r.get('error')}")

    print("DONE_ROLLOVER_WIPE")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
