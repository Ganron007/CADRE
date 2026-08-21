#!/usr/bin/env bash
# Retired always-execute full-run. Forwards to the DFIR 90-node harness (dry-run default).
# Pass --execute only after DFIR_FULL_READY=YES and reboot+wipe. No snapshots. Pin only.
echo "WARN: redstrike-campaign-v3-full-run.sh now forwards to redstrike-dfir-full.sh (graph v9, 90 nodes, pin PATH, dry-run default)." >&2
exec "$(cd "$(dirname "$0")" && pwd)/redstrike-dfir-full.sh" "$@"
