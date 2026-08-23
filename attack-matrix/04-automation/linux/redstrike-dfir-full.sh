#!/usr/bin/env bash
# DFIR full graph v9 (90 nodes) — pin on provisioning, phased beachheads.
# Default: dry-run. --execute after reboot+wipe. No VM snapshots.
# ws01-direct (Rule 1) for AD/Windows nodes. Provisioning = Kali only where the graph says so.
# Do NOT use ~/RedStrike. Do NOT run the pin on the Windows laptop.
set -euo pipefail

EXECUTE=0
NODES="${REDSTRIKE_NODES:-}"
for arg in "$@"; do
  case "${arg}" in
    --execute) EXECUTE=1 ;;
    --nodes=*) NODES="${arg#--nodes=}" ;;
    --nodes)
      echo "usage: --nodes=T009,T013 (equals form)" >&2
      exit 2
      ;;
    -h|--help)
      echo "usage: redstrike-dfir-full.sh [--execute] [--nodes=ID,ID]"
      echo "90-node graph v9, phased. Default dry-run. --execute is ungated (no HITL); scope required."
      echo "--nodes=... re-runs only those graph ids (beachhead windows; ids must allow windows)."
      exit 0
      ;;
    *)
      echo "unknown arg: ${arg}" >&2
      exit 2
      ;;
  esac
done

CADRE_ROOT="${CADRE_ROOT:-${HOME}/CADRE}"
PIN_ROOT="${CADRE_ROOT}/tools/red-strike"
PIN_VENV="${PIN_ROOT}/.venv"
PIN_BIN="${PIN_VENV}/bin"
GRAPH="${CADRE_ROOT}/attack-matrix/Campaign/automation/campaign-graph.yaml"
SEED="${REDSTRIKE_SEED:-${CADRE_ROOT}/attack-matrix/Campaign/automation/lab-seed-creds.json}"
SCOPE="${REDSTRIKE_SCOPE:-${CADRE_ROOT}/attack-matrix/Campaign/automation/scope.cadre.example.yaml}"
AUTO_ROOT="${CADRE_AUTOMATION_ROOT:-${CADRE_ROOT}/attack-matrix/04-automation/linux}"
WS01_KEY="${REDSTRIKE_WS01_SSH_KEY:-${HOME}/.ssh/cadre-ws01-key}"
READY_CHECK="${CADRE_ROOT}/tools/dfir-full-ready-check.py"
LOG_DIR="${HOME}/redstrike-runs"
MODE_TAG="dry"
if [[ "${EXECUTE}" -eq 1 ]]; then
  MODE_TAG="live"
fi
ENGAGE="${REDSTRIKE_ENGAGE:-dfir-full-${MODE_TAG}-$(date -u +%Y%m%d)}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="${LOG_DIR}/${ENGAGE}-${STAMP}.log"
MERGED="${LOG_DIR}/${ENGAGE}-${STAMP}.json"
PHASE_DIR="${LOG_DIR}/${ENGAGE}-${STAMP}-phases"

export PATH="${PIN_BIN}:/usr/bin:/bin:${HOME}/.local/bin"
export CADRE_ROOT
export CADRE_AUTOMATION_ROOT="${AUTO_ROOT}"
export REDSTRIKE_SEED="${SEED}"
export REDSTRIKE_SCOPE="${SCOPE}"
export REDSTRIKE_UNGATED=1
export REDSTRIKE_OPERATOR="provisioning"
export REDSTRIKE_WS01_SSH_KEY="${WS01_KEY}"
unset PYTHONHOME || true

mkdir -p "${LOG_DIR}" "${PHASE_DIR}"
exec > >(tee -a "${LOG}") 2>&1

echo "=== DFIR FULL graph v9 | mode=${MODE_TAG} | engage=${ENGAGE} | ${STAMP} ==="
echo "CADRE_ROOT=${CADRE_ROOT}"
echo "PIN_BIN=${PIN_BIN}"
echo "GRAPH=${GRAPH}"
echo "90 nodes, phased beachheads, no snapshots"

fail() { echo "DFIR_FULL_READY=NO" >&2; echo "FAIL: $*" >&2; exit 1; }

[[ -d "${PIN_ROOT}" ]] || fail "pin missing at ${PIN_ROOT}"
[[ -x "${PIN_BIN}/redstrike-campaign" ]] || fail "pin venv missing ${PIN_BIN}/redstrike-campaign"
[[ -f "${GRAPH}" ]] || fail "CADRE graph missing ${GRAPH}"
[[ -f "${SEED}" ]] || fail "seed missing ${SEED}"
[[ -f "${SCOPE}" ]] || fail "scope missing ${SCOPE} (ungated lab requires targets + domains)"
[[ -d "${AUTO_ROOT}" ]] || fail "automation root missing ${AUTO_ROOT}"
[[ -x "${AUTO_ROOT}/lib/ws01-exec.sh" ]] || fail "ws01-exec.sh missing"
[[ -x "${AUTO_ROOT}/lib/linux01-exec.sh" ]] || fail "linux01-exec.sh missing (branch D)"
[[ -f "${AUTO_ROOT}/campaign-h/H-01-lnk.sh" ]] || fail "H-01 script missing"
[[ -f "${WS01_KEY}" ]] || fail "ws01 SSH key missing ${WS01_KEY}"
[[ -f "${READY_CHECK}" ]] || fail "ready-check missing ${READY_CHECK}"

WHICH_BIN="$(command -v redstrike-campaign || true)"
[[ "${WHICH_BIN}" == "${PIN_BIN}/redstrike-campaign" ]] || fail "redstrike-campaign is ${WHICH_BIN:-NONE} — want pin"

python3 - "${GRAPH}" <<'PY' || fail "graph is not CADRE v9 with 90 nodes"
import sys
from pathlib import Path
text = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
if "name: cadre-campaign-m5" not in text:
    raise SystemExit("graph name is not cadre-campaign-m5")
if not any(line.strip() == "version: 9" for line in text.splitlines()[:20]):
    raise SystemExit("graph version is not 9")
n = sum(1 for line in text.splitlines() if line.startswith("  - id:"))
if n != 90:
    raise SystemExit(f"graph node count {n} != 90")
PY

echo "--- pin identity ---"
"${PIN_BIN}/python" -c "import redstrike,inspect; print('redstrike', redstrike.__version__, inspect.getfile(redstrike))"

if [[ "${EXECUTE}" -eq 1 ]]; then
  echo "--- ws01 SSH (analyst_t1) ---"
  ssh -i "${WS01_KEY}" -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
    analyst_t1@192.168.77.62 "whoami && hostname && echo SSH_OK"
fi

COMMON=(
  --engage "${ENGAGE}"
  --operator provisioning
  --cadre-root "${CADRE_ROOT}"
  --graph "${GRAPH}"
  --seed "${SEED}"
  --scope "${SCOPE}"
  --ungated
  --automation-root "${AUTO_ROOT}"
  --json
)

echo "--- start ---"
redstrike-campaign start --beachhead windows "${COMMON[@]}"

if [[ "${EXECUTE}" -eq 1 ]]; then
  echo "NOTE: --execute uses --ungated (no HITL). Scope file is required (${SCOPE})."
  for gate in dcsync ticket forest persistence acl_write site_takeover; do
    redstrike-campaign approve --gate "${gate}" --note "dfir-full collection" --beachhead windows "${COMMON[@]}"
  done
fi

extract_json() {
  python3 - "$1" <<'PY'
import json, sys
from pathlib import Path
raw = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
dec = json.JSONDecoder()
obj = None
idx = 0
while idx < len(raw):
    while idx < len(raw) and raw[idx].isspace():
        idx += 1
    if idx >= len(raw):
        break
    try:
        obj, end = dec.raw_decode(raw, idx)
        idx = end
    except json.JSONDecodeError:
        idx += 1
if not isinstance(obj, dict) or "steps" not in obj:
    raise SystemExit(f"no campaign JSON in {sys.argv[1]}")
Path(sys.argv[1]).write_text(json.dumps(obj, indent=2) + "\n", encoding="utf-8")
PY
}

PHASE_FILES=()
run_phase() {
  local phase="$1"
  local branch="$2"
  local beach="$3"
  local safe
  safe="$(echo "${branch}-${phase}-${beach}" | tr '/,' '__')"
  local out="${PHASE_DIR}/${safe}.json"
  echo "--- plan/run phase=${phase} branch=${branch} beachhead=${beach} ---"
  local args=(
    run
    "${COMMON[@]}"
    --branch "${branch}"
    --phase "${phase}"
    --beachhead "${beach}"
    --profile P-DFIR
    --prefer-script
  )
  if [[ "${EXECUTE}" -eq 1 ]]; then
    args+=(--execute --no-stop-on-hitl)
  fi
  if [[ -n "${NODES}" ]]; then
    args+=(--nodes "${NODES}")
  fi
  set +e
  redstrike-campaign "${args[@]}" > "${out}.raw"
  local rc=$?
  set -e
  cp "${out}.raw" "${out}"
  extract_json "${out}"
  PHASE_FILES+=("${out}")
  if [[ "${EXECUTE}" -eq 1 && "${rc}" -ne 0 ]]; then
    echo "WARN: phase ${phase} branch ${branch} beachhead ${beach} rc=${rc}"
  fi
}

# Phased calibration (graph v9). Windows = ws01-exec. linux = Kali/provisioning origin.
if [[ -n "${NODES}" ]]; then
  echo "--- node retry: ${NODES} ---"
  run_phase "0-10" all windows
else
run_phase "0" spine linux              # T028 null-session from .60
run_phase "0.5-3" spine windows        # H-ASSUME + roast + SQL
run_phase "3.5-4" spine windows
run_phase "5-8" spine windows
run_phase "4-5" A windows
run_phase "5" B windows
run_phase "8" C windows
run_phase "3-3.5" D windows            # T040/T044 linked hop from ws01
run_phase "3.5" D linux                # T045-T048 on linux01
run_phase "1" G linux                  # T031 spray from .60
run_phase "5" G windows                # T007 RBCD from ws01
run_phase "0.5" H linux                # H-01..H-06 Kali→ws01 (Rule 4)
run_phase "9" E linux
run_phase "10" F linux
run_phase "3" sql-ai windows           # stub, still a graph node
fi

python3 - "${MERGED}" "${PHASE_FILES[@]}" <<'PY'
import json, sys
from pathlib import Path
out = Path(sys.argv[1])
steps = []
seen = set()
meta = {}
for p in sys.argv[2:]:
    data = json.loads(Path(p).read_text(encoding="utf-8"))
    meta = {
        "engagement_id": data.get("engagement_id"),
        "operator": data.get("operator"),
        "graph": data.get("graph"),
        "graph_name": data.get("graph_name"),
        "profile": data.get("profile"),
        "preflight": data.get("preflight"),
    }
    for step in data.get("steps") or []:
        nid = step.get("node_id")
        if nid in seen:
            continue
        seen.add(nid)
        steps.append(step)
starts = [s.get("started_at") for s in steps if s.get("started_at")]
ends = [s.get("finished_at") for s in steps if s.get("finished_at")]
merged = {
    **meta,
    "beachhead": "mixed",
    "branches": sorted({s.get("branch") for s in steps if s.get("branch")}),
    "started_at": min(starts) if starts else None,
    "finished_at": max(ends) if ends else None,
    "steps": steps,
    "ws01_exec_count": sum(1 for s in steps if s.get("uses_ws01_exec") and not s.get("skipped")),
    "local_ws01_count": sum(1 for s in steps if s.get("mechanism") == "local-ws01"),
    "linux_direct_count": sum(1 for s in steps if s.get("mechanism") == "direct-linux60" and not s.get("skipped")),
    "kali_origin_count": sum(
        1 for s in steps if s.get("mechanism") in ("direct-linux60", "external60_phase0") and not s.get("skipped")
    ),
    "stub_count": sum(1 for s in steps if s.get("stub") or (s.get("skipped") and "stub" in str(s.get("skip_reason") or ""))),
    "verified_count": sum(1 for s in steps if s.get("verified")),
    "unverified_count": sum(
        1
        for s in steps
        if not s.get("dry_run") and not s.get("skipped") and not s.get("awaiting_approval") and not s.get("verified")
    ),
    "node_count": len(steps),
}
out.write_text(json.dumps(merged, indent=2) + "\n", encoding="utf-8")
print(f"merged nodes={merged['node_count']} ws01_exec={merged['ws01_exec_count']} linux={merged['linux_direct_count']}")
PY

echo "--- ready-check ---"
READY_ARGS=()
if [[ -n "${NODES}" ]]; then
  READY_ARGS+=(--subset)
fi
if [[ "${EXECUTE}" -eq 1 ]]; then
  READY_ARGS+=(--require-verified)
fi
python3 "${READY_CHECK}" "${READY_ARGS[@]}" "${MERGED}"
READY_RC=$?
echo "log=${LOG}"
echo "json=${MERGED}"
if [[ "${READY_RC}" -ne 0 ]]; then
  if [[ "${EXECUTE}" -eq 1 ]]; then
    echo "Execute dump failed verification. rc=0 banners are not attack success." >&2
  else
    echo "Wiring is not ready. Do not treat execute as done." >&2
  fi
  exit 1
fi
if [[ "${EXECUTE}" -eq 1 ]]; then
  echo "DFIR_FULL_EXECUTE verified in-engine. json=${MERGED}"
  exit 0
fi
echo "Dry-run wiring proved for full graph. Wait for reboot+wipe then --execute."
exit 0
