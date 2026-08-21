#!/usr/bin/env bash
# Retired 30-node DFIR spine wrapper. Forwards to the 90-node full-graph harness.
echo "WARN: redstrike-dfir-spine.sh is retired (30-node spine). Forwarding to redstrike-dfir-full.sh (graph v9, 90 nodes)." >&2
exec "$(cd "$(dirname "$0")" && pwd)/redstrike-dfir-full.sh" "$@"
