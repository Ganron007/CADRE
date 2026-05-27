#!/usr/bin/env python3
"""CADRE — Cloud · Agentic · DFIR · Red-team · Environment

Modern interactive CLI with real-time output streaming, live file/config tracking,
structured Ansible event parsing, and an interactive menu system.
"""

import json
import subprocess
import sys
import re
from pathlib import Path
from datetime import timedelta
from time import time as _time
from os import environ as _environ

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.table import Table
    from rich.live import Live
    from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
    from rich.layout import Layout
    from rich.text import Text
    from rich.prompt import Prompt, Confirm
    from rich.rule import Rule
    from rich.columns import Columns
    HAS_RICH = True
except ImportError:
    print("ERROR: 'rich' is required. Install with: pip install rich", file=sys.stderr)
    sys.exit(1)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

PROJECT_ROOT = Path(__file__).parent.resolve()
PROVIDER_DIR = PROJECT_ROOT / "lab" / "providers" / "vmware"
DATA_DIR = PROJECT_ROOT / "lab" / "data"
ANSIBLE_DIR = PROJECT_ROOT / "ansible"
CONFIG_PATH = DATA_DIR / "config.json"

# Try to locate vmrun.exe (VMware Workstation CLI)
_VMRUN_CANDIDATES = [
    Path("C:/Program Files (x86)/VMware/VMware Workstation/vmrun.exe"),
    Path("C:/Program Files/VMware/VMware Workstation/vmrun.exe"),
    Path("C:/Program Files (x86)/VMware/VMware Player/vmrun.exe"),
]
VMRUN_PATH = None
for _c in _VMRUN_CANDIDATES:
    if _c.exists():
        VMRUN_PATH = str(_c)
        break

PHASES = [
    ("00-domain-deploy",         "playbooks/00-domain-deploy.yml",         "Phase 00 — Domain promotion, DNS, trusts (fresh deploy)", 10),
    ("01-core-ad",               "playbooks/01-core-ad.yml",               "Phase 01 — Core AD: domains, trusts (verify)", 3),
    ("02-ad-objects",            "playbooks/02-ad-objects.yml",            "Phase 02 — OUs, users, groups, GPOs", 8),
    ("03-member-join",           "playbooks/03-member-join.yml",           "Phase 03 — Member domain joins (mbr01, mbr02)", 4),
    ("04-windows-features",      "playbooks/04-windows-features.yml",      "Phase 04 — IIS, WSUS features", 4),
    ("04-vulnerabilities",       "playbooks/04-vulnerabilities.yml",       "Phase 05 — Registry, services, features", 6),
    ("05-ad-attack-surface",     "playbooks/05-ad-attack-surface.yml",     "Phase 06 — ACEs, SPNs, AS-REP, delegation", 10),
    ("06-member-services",       "playbooks/06-member-services.yml",       "Phase 07 — Shares, bait, app pool, VSC verify", 4),
    ("07-linux-infra",           "playbooks/07-linux-infra.yml",           "Phase 08 — Linux infra: realm join, pkgs", 8),
    ("07-linux-config",          "playbooks/07-linux-config.yml",          "Phase 09 — Linux config: SSSD, auditd, NFS, podman", 4),
    ("08-adcs-verify",           "playbooks/08-adcs-verify.yml",           "Phase 10 — ADCS verification (manual CA install)", 3),
    ("09-sql-wsus-verify",       "playbooks/09-sql-wsus-verify.yml",       "Phase 11 — SQL + WSUS verification (manual SQL install)", 3),
    ("10-sccm-verify",           "playbooks/10-sccm-verify.yml",           "Phase 12 — SCCM verification (manual install)", 3),
    ("11-security-baseline",     "playbooks/11-security-baseline.yml",     "Phase 13 — Audit, PS logging, NTLM, Sysmon", 4),
    ("12-elk-fleet",             "playbooks/12-elk-fleet.yml",             "Phase 14 — Elastic 9.x + Fleet (extension)", 6),
    ("13-net-monitor",           "playbooks/13-net-monitor.yml",           "Phase 15 — Zeek + Suricata + Arkime (extension)", 6),
    ("14-velociraptor",          "playbooks/14-velociraptor.yml",          "Phase 16 — Velociraptor server + clients (extension)", 4),
    ("15-cloud-sync",            "playbooks/15-cloud-sync.yml",            "Phase 17 — Entra Cloud Sync agent (dc01)", 3),
]
PHASE_NAMES = [p[0] for p in PHASES]

# Core VMs always brought up by `vagrant up`.
CORE_VM_NAMES = {"dc01", "dc02", "dc03", "mbr01", "mbr02", "linux01", "provisioning"}

# Extension name -> (vm_name, ip, ssh_port). VM gated in the Vagrantfile by CADRE_EXTENSIONS.
EXTRA_VMS = {
    "elk-fleet":    ("elk",     "192.168.77.50", 22),
    "velociraptor": ("vr",      "192.168.77.51", 22),
    "net-monitor":  ("monitor", "192.168.77.55", 22),
}

# Phase IDs that deploy an extension (run only via the -e selection loop, NOT the
# main phase loop — otherwise they'd run against a VM that may not exist + double-run).
EXT_PHASE_IDS = {"12-elk-fleet", "13-net-monitor", "14-velociraptor"}

console = Console()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def run(cmd, cwd=None, timeout=None, env=None):
    """Run a command, capture output (for quick checks only)."""
    return subprocess.run(
        cmd,
        cwd=cwd or PROJECT_ROOT,
        capture_output=True,
        text=True,
        timeout=timeout,
        env=env,
    )


def run_stream(cmd, cwd=None, timeout=None, callback=None, verbose=0, env=None):
    """Run a command, stream output line-by-line in real-time.

    Args:
        cmd: Command list
        cwd: Working directory
        timeout: Max seconds to wait
        callback: Function(line) called for each line
        verbose: 0=silent, 1=summary, 2=task names, 3+=full raw
        env: Optional environment dict (defaults to inherited environment)
    """
    proc = subprocess.Popen(
        cmd,
        cwd=cwd or PROJECT_ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
        errors="replace",
        env=env,
    )
    try:
        for line in iter(proc.stdout.readline, ""):
            if callback:
                callback(line)
            if verbose >= 3:
                print(line, end="")
        return proc.wait(timeout=timeout)
    except KeyboardInterrupt:
        proc.kill()
        proc.wait()
        raise


def run_vagrant(args, cwd=None, verbose=0, callback=None, stream=False, env=None):
    """Run vagrant. If stream=True, stream output and return exit code.

    env: optional environment dict. Used to pass CADRE_EXTENSIONS so the
    Vagrantfile includes the selected extension VMs (elk/monitor/vr).
    """
    target = cwd or PROVIDER_DIR
    if stream:
        return run_stream(
            ["vagrant"] + args,
            cwd=target,
            verbose=verbose,
            callback=callback,
            env=env,
        )
    return run(["vagrant"] + args, cwd=target, env=env)


def _find_vmx_files(vm_dir):
    """Yield (name, vmx_path) for every provisioned VM in vm_dir."""
    machines = Path(vm_dir) / ".vagrant" / "machines"
    if not machines.exists():
        return
    for vm_name in sorted(machines.iterdir()):
        prov_dir = vm_name / "vmware_desktop"
        if not prov_dir.exists():
            continue
        for entry in prov_dir.iterdir():
            vmx = list(entry.glob("*.vmx"))
            if vmx:
                yield vm_name.name, str(vmx[0])


def _vmrun_start(vmx_path, callback=None):
    """Power on a VM instantly via vmrun. Returns exit code."""
    if not VMRUN_PATH:
        return -1
    line = f"vmrun start {Path(vmx_path).name}"
    if callback:
        callback(line)
    r = run([VMRUN_PATH, "-T", "ws", "start", vmx_path])
    return r.returncode


def _vmrun_running(vm_dir):
    """Return set of VMX paths currently running."""
    if not VMRUN_PATH:
        return set()
    r = run([VMRUN_PATH, "-T", "ws", "list"])
    if r.returncode != 0:
        return set()
    paths = set()
    for line in r.stdout.splitlines():
        line = line.strip()
        if line.endswith(".vmx") and Path(line).exists():
            paths.add(line)
    return paths


def _existing_vms(vm_dir):
    """Return True if at least one VM has been provisioned in vm_dir."""
    for _ in _find_vmx_files(vm_dir):
        return True
    return False


def _vmrun_start_all(vm_dir, callback=None):
    """Start all provisioned VMs sequentially via vmrun. Returns (ok, fail) count."""
    ok = fail = 0
    vmx_list = list(_find_vmx_files(vm_dir))
    running = _vmrun_running(vm_dir)

    for name, vmx_path in vmx_list:
        if vmx_path in running:
            if callback:
                callback(f"  {name} already running")
            ok += 1
            continue
        rc = _vmrun_start(vmx_path, callback)
        if rc == 0:
            ok += 1
        else:
            if callback:
                callback(f"  {name} FAILED")
            fail += 1

    return ok, fail


def _health_check(vm_dir, callback=None, timeout=300, extra_vms=None):
    """Parallel health check: ping + port probe for core VMs.

    Core VMs are always checked. Extension VMs can be passed via extra_vms dict.

    Returns dict of {name: True/False}.
    """
    import socket, concurrent.futures

    vms = {
        "dc01":  ("192.168.77.10", 5985),
        "dc02":  ("192.168.77.11", 5985),
        "dc03":  ("192.168.77.12", 5985),
        "mbr01": ("192.168.77.22", 5985),
        "mbr02": ("192.168.77.23", 5985),
        "linux01":   ("192.168.77.40", 22),
        "provisioning": ("192.168.77.60", 22),
    }
    if extra_vms:
        vms.update(extra_vms)

    results = {}

    def _probe(name, ip, port):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)
            s.connect((ip, port))
            s.close()
            return name, True
        except (socket.timeout, ConnectionRefusedError, OSError):
            return name, False

    if callback:
        callback("  Health check: pinging all VMs...")

    with concurrent.futures.ThreadPoolExecutor(max_workers=11) as pool:
        fut = {pool.submit(_probe, n, ip, p): n for n, (ip, p) in vms.items()}
        done, _ = concurrent.futures.wait(fut, timeout=timeout)
        for f in done:
            name = fut[f]
            try:
                _, ok = f.result()
                results[name] = ok
            except Exception:
                results[name] = False

    return results


def check_admin():
    import ctypes
    return ctypes.windll.shell32.IsUserAnAdmin() != 0


def check_ram_gb():
    r = run([
        "powershell", "-Command",
        "(Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB"
    ])
    try:
        return int(float(r.stdout.strip()))
    except (ValueError, TypeError):
        return 0


def check_disk_gb(path="C:"):
    r = run([
        "powershell", "-Command",
        f"(Get-PSDrive {path[0]}).Free"
    ])
    try:
        return int(r.stdout.strip()) // (1024 ** 3)
    except (ValueError, TypeError):
        return 0


def find_provisioning_key(vm_dir=None):
    search_dir = Path(vm_dir or PROVIDER_DIR)
    key_paths = list(search_dir.rglob("private_key"))
    for kp in key_paths:
        if Path("provisioning") in kp.parents or "provisioning" in kp.parts:
            return kp
    if key_paths:
        return key_paths[0]
    insecure = Path.home() / ".vagrant.d" / "insecure_private_key"
    return insecure if insecure.exists() else None


def get_provisioning_ip(vm_dir=None):
    """Return 192.168.77.60 — static vmnet2 IP for the provisioning VM.

    All 11 VMs use static IPs on 192.168.77.0/24 (vmnet2). Ansible
    (running on the provisioning VM) needs to reach other VMs over
    the vmnet2 private network, not via vagrant's NAT/forwarded ports.
    """
    return "192.168.77.60"


# ---------------------------------------------------------------------------
# Ansible Event Parser — structured JSON callback
# ---------------------------------------------------------------------------

_ANSIBLE_EVENT_RE = re.compile(r'^\{.*"event".*\}$')


def _parse_ansible_json_line(line):
    """Try to parse a line as Ansible JSON callback event. Returns dict or None."""
    stripped = line.strip()
    if not stripped.startswith("{"):
        return None
    try:
        obj = json.loads(stripped)
        if "event" in obj:
            return obj
    except (json.JSONDecodeError, ValueError):
        pass
    return None


def _extract_task_name(event):
    """Extract a readable task name from an Ansible JSON event."""
    task = event.get("task", {})
    if isinstance(task, dict):
        return task.get("name", "unknown")
    return str(task)


def _extract_play_name(event):
    """Extract play name from an Ansible JSON event."""
    play = event.get("play", {})
    if isinstance(play, dict):
        return play.get("name", "unknown")
    return str(play)


def _extract_host(event):
    """Extract host from an Ansible JSON event."""
    res = event.get("res", {})
    if isinstance(res, dict):
        return res.get("_ansible_no_log", False)
    return event.get("host", "unknown")


def _extract_result_summary(event):
    """Get a short result summary from an Ansible JSON event."""
    res = event.get("res", {})
    if not isinstance(res, dict):
        return ""
    if res.get("failed"):
        msg = res.get("msg", "") or res.get("stderr", "") or "failed"
        return f"FAILED: {msg[:120]}"
    if res.get("changed"):
        return "changed"
    if res.get("skipped"):
        return "skipped"
    return "ok"


# ---------------------------------------------------------------------------
# Play Tracker — tracks per-play timing and task results
# ---------------------------------------------------------------------------

class PlayRecord:
    """Records timing and results for a single play."""

    def __init__(self, name, start_time):
        self.name = name
        self.start_time = start_time
        self.end_time = None
        self.ok = 0
        self.changed = 0
        self.failed = 0
        self.skipped = 0
        self.unreachable = 0

    @property
    def duration(self):
        if self.end_time:
            return self.end_time - self.start_time
        return _time() - self.start_time

    @property
    def total(self):
        return self.ok + self.changed + self.failed + self.skipped + self.unreachable


class DeployTracker:
    """Tracks the entire deployment: plays, tasks, files, AD objects, etc."""

    def __init__(self):
        self.plays = []
        self.current_play = None
        self.current_task = ""
        self.task_count = 0
        self.total_tasks = 0
        self.files_created = []
        self.registry_changes = []
        self.service_changes = []
        self.gpo_changes = []
        self.ad_objects = []
        self.packages_installed = []
        self.errors = []
        self.last_output_lines = []
        self.max_output = 20
        self._seen_tasks = set()

    def start_play(self, name, now=None):
        t = now or _time()
        self.current_play = PlayRecord(name, t)
        self.plays.append(self.current_play)

    def end_play(self, now=None):
        if self.current_play:
            self.current_play.end_time = now or _time()

    def record_task(self, event):
        """Record a task result from an Ansible JSON event."""
        self.task_count += 1
        task_name = _extract_task_name(event)
        self.current_task = task_name
        event_type = event.get("event", "")
        host = event.get("host", "unknown")

        if not self.current_play:
            self.start_play("Unknown")

        if event_type == "runner_on_ok":
            res = event.get("res", {})
            if isinstance(res, dict) and res.get("changed"):
                self.current_play.changed += 1
            else:
                self.current_play.ok += 1
        elif event_type == "runner_on_failed":
            self.current_play.failed += 1
            self.errors.append(f"{task_name} on {host}")
        elif event_type == "runner_on_skipped":
            self.current_play.skipped += 1
        elif event_type == "runner_on_unreachable":
            self.current_play.unreachable += 1
            self.errors.append(f"Unreachable: {host}")

        # Track specific change types
        if event_type == "runner_on_ok" or event_type == "runner_on_failed":
            res = event.get("res", {})
            if isinstance(res, dict):
                invocation = res.get("invocation", {})
                module_args = invocation.get("module_args", {}) if isinstance(invocation, dict) else {}
                if module_args.get("dest") or module_args.get("path"):
                    p = module_args.get("dest") or module_args.get("path")
                    if p and len(str(p)) > 2:
                        self.files_created.append(str(p))

        # Keep recent output
        status_icon = {"runner_on_ok": "✓", "runner_on_failed": "✗",
                       "runner_on_skipped": "⊘", "runner_on_unreachable": "!"}
        icon = status_icon.get(event_type, "·")
        self.last_output_lines.append(f"{icon} {task_name}")
        if len(self.last_output_lines) > self.max_output:
            self.last_output_lines.pop(0)

    def parse_line(self, line):
        """Parse a line — try JSON first, fall back to regex."""
        stripped = line.strip()
        if not stripped:
            return

        event = _parse_ansible_json_line(stripped)
        if event:
            self.record_task(event)
            return

        # Fallback: regex parsing for non-JSON output (vagrant, galaxy, etc.)
        if stripped.startswith("PLAY ["):
            name = stripped.replace("PLAY [", "").rstrip("]")
            self.start_play(name)
        elif stripped.startswith("TASK ["):
            self.current_task = stripped.replace("TASK [", "").rstrip("]")
            self.task_count += 1
        elif "changed:" in stripped:
            if self.current_play:
                self.current_play.changed += 1
        elif "ok:" in stripped and "changed" not in stripped:
            if self.current_play:
                self.current_play.ok += 1
        elif "failed:" in stripped or "FAILED" in stripped:
            if self.current_play:
                self.current_play.failed += 1
            host = stripped.split("failed:")[-1].strip() if "failed:" in stripped else "unknown"
            self.errors.append(f"{self.current_task} on {host}")
        elif "skipping:" in stripped:
            if self.current_play:
                self.current_play.skipped += 1

    @property
    def total_ok(self):
        return sum(p.ok for p in self.plays)

    @property
    def total_changed(self):
        return sum(p.changed for p in self.plays)

    @property
    def total_failed(self):
        return sum(p.failed for p in self.plays)

    @property
    def total_skipped(self):
        return sum(p.skipped for p in self.plays)

    @property
    def total_tasks_all(self):
        return self.total_ok + self.total_changed + self.total_failed + self.total_skipped

    def summary_table(self):
        """Rich table: per-play timing and results."""
        table = Table(show_header=True, box=None, padding=(0, 2))
        table.add_column("Play", style="bold cyan")
        table.add_column("Time", style="dim")
        table.add_column("OK", style="green")
        table.add_column("Changed", style="yellow")
        table.add_column("Failed", style="red")
        table.add_column("Skipped", style="dim")
        table.add_column("Total", style="bold")

        for p in self.plays:
            table.add_row(
                p.name,
                str(timedelta(seconds=int(p.duration))),
                str(p.ok),
                str(p.changed),
                str(p.failed),
                str(p.skipped),
                str(p.total),
            )

        return table

    def final_summary(self):
        """Overall deployment summary."""
        table = Table(show_header=False, box=None, padding=(0, 1))
        table.add_column("Metric", style="bold cyan")
        table.add_column("Value", style="bold white")

        table.add_row("Total Plays", str(len(self.plays)))
        table.add_row("Total Tasks", str(self.total_tasks_all))
        table.add_row("OK", str(self.total_ok))
        table.add_row("Changed", str(self.total_changed))
        if self.total_failed > 0:
            table.add_row("Failed", f"[red]{self.total_failed}[/red]")
        table.add_row("Skipped", str(self.total_skipped))
        if self.errors:
            table.add_row("Errors", f"[red]{len(self.errors)}[/red]")
        if self.files_created:
            table.add_row("Files Created", str(len(self.files_created)))
        if self.ad_objects:
            table.add_row("AD Objects", str(len(self.ad_objects)))

        return table


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_check(verbose=0):
    """Pre-flight check with Rich formatting."""
    if HAS_RICH:
        console.print(Rule("CADRE Pre-flight Check", style="bold cyan"))
    else:
        print("\n=== CADRE Pre-flight Check ===\n")

    results = []
    results.append(("Admin", check_admin(), "Must run as Administrator"))
    results.append(("RAM >= 36GB", check_ram_gb() >= 36, f"Has {check_ram_gb()} GB"))
    results.append(("Disk >= 150GB", check_disk_gb() >= 150, f"Free {check_disk_gb()} GB"))

    vagrant_ver = run(["vagrant", "--version"])
    v_ok = vagrant_ver.returncode == 0 and "Vagrant" in vagrant_ver.stdout
    results.append(("Vagrant installed", v_ok, vagrant_ver.stdout.strip() if v_ok else vagrant_ver.stderr.strip()))

    svc = run(["powershell", "-Command", "(Get-Service vagrant-vmware-utility).Status"])
    svc_ok = "Running" in svc.stdout
    results.append(("VMware Utility running", svc_ok, svc.stdout.strip()))

    plugin_list = run_vagrant(["plugin", "list"])
    for plugin in ["vagrant-vmware-desktop", "vagrant-reload"]:
        has_it = plugin in plugin_list.stdout
        results.append((f"Plugin: {plugin}", has_it, "installed" if has_it else "MISSING"))

    if HAS_RICH:
        table = Table(show_header=False, box=None)
        table.add_column("Status", width=4)
        table.add_column("Check")
        table.add_column("Detail")

        all_pass = True
        for name, ok, detail in results:
            status = "[green]+[/green]" if ok else "[red]-[/red]"
            table.add_row(status, name, detail)
            if not ok:
                all_pass = False

        console.print(table)

        if CONFIG_PATH.exists():
            cfg = json.loads(CONFIG_PATH.read_text())
            console.print(f"\n[dim]Config:[/dim] {CONFIG_PATH.name} — {len(cfg.get('domains', []))} domains, "
                          f"{sum(len(d.get('users', [])) for d in cfg.get('domains', []))} users")

        sccm_media = PROJECT_ROOT / "ansible" / "roles" / "sccm" / "files" / "ConfigMgr_2509.exe"
        cs_media = PROJECT_ROOT / "ansible" / "roles" / "cloud" / "files" / "AADConnectProvisioningAgentSetup.exe"
        sccm_ok = sccm_media.exists()
        cs_ok = cs_media.exists()
        console.print(f"\n[dim]Media:[/dim] SCCM eval EXE = {'[green]+[/green]' if sccm_ok else '[red]-[/red]'} present")
        console.print(f"        Cloud Sync agent = {'[green]+[/green]' if cs_ok else '[red]-[/red]'} present")
        if not sccm_ok or not cs_ok:
            console.print("        [yellow]Run: pwsh docs/internal/tools/download-media/download-media.ps1[/yellow]")

        console.print(f"\n[bold green]ALL CHECKS PASSED[/bold green]" if all_pass else "[bold red]SOME CHECKS FAILED[/bold red]")
    else:
        print("\n=== CADRE Pre-flight Check ===\n")
        all_pass = True
        for name, ok, detail in results:
            status = "[+]" if ok else "[-]"
            print(f"  {status} {name}: {detail}")
            if not ok:
                all_pass = False

        if CONFIG_PATH.exists():
            cfg = json.loads(CONFIG_PATH.read_text())
            print(f"\n  Config: {CONFIG_PATH.name} — {len(cfg.get('domains', []))} domains, "
                  f"{sum(len(d.get('users', [])) for d in cfg.get('domains', []))} users")

        sccm_media = PROJECT_ROOT / "ansible" / "roles" / "sccm" / "files" / "ConfigMgr_2509.exe"
        cs_media = PROJECT_ROOT / "ansible" / "roles" / "cloud" / "files" / "AADConnectProvisioningAgentSetup.exe"
        print(f"\n  Media: SCCM eval EXE = {'[+]' if sccm_media.exists() else '[-]'} present")
        print(f"         Cloud Sync agent = {'[+]' if cs_media.exists() else '[-]'} present")
        if not sccm_media.exists() or not cs_media.exists():
            print(f"         Run: pwsh docs/internal/tools/download-media/download-media.ps1")

        print(f"\n  Result: {'ALL CHECKS PASSED' if all_pass else 'SOME CHECKS FAILED'}")

    return 0 if all_pass else 1


def _run_ansible_playbook(ssh_opts, prov_user, prov_ip, playbook, tracker, verbose=0):
    """Run a single Ansible playbook with structured event tracking."""
    if verbose >= 3:
        cmd = (
            f"cd /home/vagrant/ansible && "
            f"ansible-playbook -i inventories/hosts {playbook}"
        )
    else:
        cmd = (
            f"cd /home/vagrant/ansible && "
            f"ANSIBLE_STDOUT_CALLBACK=json "
            f"ansible-playbook -i inventories/hosts {playbook}"
        )

    rc = run_stream(
        ["ssh"] + ssh_opts + [f"{prov_user}@{prov_ip}", cmd],
        timeout=7200,
        callback=lambda line: tracker.parse_line(line),
        verbose=verbose,
    )
    return rc


def _run_ansible_with_progress(ssh_opts, prov_user, prov_ip, playbook, tracker, verbose=0, phase_name=None, max_plays=9):
    """Run Ansible with Rich progress bar and live task display."""
    if not HAS_RICH:
        return _run_ansible_playbook(ssh_opts, prov_user, prov_ip, playbook, tracker, verbose)

    start = _time()

    with Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(bar_width=40),
        TaskProgressColumn(),
        TextColumn("[dim]{task.fields[detail]}"),
        transient=False,
    ) as progress:

        label = phase_name or "Ansible"
        main_task = progress.add_task(
            label,
            total=100,
            detail="Starting...",
        )

        def on_line(line):
            tracker.parse_line(line)
            plays_done = len(tracker.plays)
            status = tracker.current_task or "Starting..."
            if plays_done > 0:
                pct = min(95, int((plays_done / max_plays) * 100))
                detail = f"Play {plays_done}/{max_plays} — {status}"
                if phase_name:
                    detail = f"{phase_name}: {detail}"
                progress.update(main_task, completed=pct, detail=detail)
            else:
                progress.update(main_task, completed=2, detail="Starting...")

        rc = run_stream(
            ["ssh"] + ssh_opts + [f"{prov_user}@{prov_ip}",
             f"cd /home/vagrant/ansible && "
             f"ANSIBLE_STDOUT_CALLBACK=json "
             f"ansible-playbook -i inventories/hosts {playbook}"],
            timeout=7200,
            callback=on_line,
            verbose=verbose,
        )

        elapsed = timedelta(seconds=int(_time() - start))
        progress.update(main_task, completed=100, detail=f"{label}: Done ({elapsed})")

    return rc


def cmd_install(verbose=None, extensions=None, vm_dir=None, auto_approve=False, from_phase=None):
    """Full install with live tracking."""
    if not CONFIG_PATH.exists():
        eprint(f"Config not found at {CONFIG_PATH}")
        return 1
    if not (PROVIDER_DIR / "Vagrantfile").exists():
        eprint(f"Vagrantfile not found at {PROVIDER_DIR / 'Vagrantfile'}")
        return 1

    if auto_approve:
        if not vm_dir:
            default_parent = Path(_environ.get("USERPROFILE") or Path.home()) / "VMs"
            vm_dir = _resolve_install_dir(str(default_parent))
        else:
            vm_dir = Path(vm_dir).resolve()
            if vm_dir.name != INSTALL_FOLDER_NAME:
                vm_dir = vm_dir / INSTALL_FOLDER_NAME
        if extensions is None:
            extensions = ["elk-fleet", "net-monitor", "velociraptor"]
        if verbose is None:
            verbose = 2
    else:
        vm_dir = _get_vm_dir(vm_dir)

        if extensions is None:
            extensions = _prompt_extensions()

        if verbose is None:
            verbose = _prompt_verbosity()

        if not _show_install_summary(vm_dir, extensions, verbose):
            console.print("[yellow]Install cancelled by user.[/yellow]")
            return 0

    _ensure_vm_dir(vm_dir)
    console.print(f"[dim]Install directory ready:[/dim] {vm_dir}")

    tracker = DeployTracker()
    start_time = _time()

    if HAS_RICH:
        console.print(Rule("CADRE Deploy", style="bold cyan"))
    else:
        print("\n=== CADRE Deploy ===\n")

    # Phase 1: Bring up VMs
    phase = "Phase 1/3 — Bringing up VMs"
    if HAS_RICH:
        console.print(f"\n[bold blue]{phase}[/bold blue]")
    else:
        print(f"\n[*] {phase}")

    # CADRE_EXTENSIONS tells the Vagrantfile which extension VMs (elk/monitor/vr) to include.
    vagrant_env = dict(_environ)
    vagrant_env["CADRE_EXTENSIONS"] = ",".join(extensions or [])

    # Expected VMs this run = core + the VM behind each selected extension.
    ext_vm_names = {EXTRA_VMS[e][0] for e in (extensions or []) if e in EXTRA_VMS}
    existing_names = {name for name, _ in _find_vmx_files(vm_dir)}
    missing = (CORE_VM_NAMES | ext_vm_names) - existing_names

    if existing_names and not missing:
        # Everything already provisioned (incl. any selected extension VMs) → fast power-on.
        console.print("  VMs already provisioned — powering on via vmrun (instant)...")
        ok, fail = _vmrun_start_all(vm_dir, callback=lambda line: tracker.parse_line(line))
        if fail:
            console.print(f"[red]{fail} VM(s) failed to start[/red]")
            return 1
        console.print(f"  [green]{ok} VMs powered on[/green]")
    else:
        # Fresh deploy, or a newly-selected extension VM not yet created → vagrant up.
        # `vagrant up` is idempotent: it creates missing VMs and starts existing ones.
        if existing_names:
            console.print(f"  Creating/starting VMs (new: {', '.join(sorted(missing)) or 'none'})...")
        def on_vagrant_line(line):
            tracker.parse_line(line)
        rc = run_vagrant(["up"], cwd=str(vm_dir), verbose=verbose,
                         callback=on_vagrant_line, stream=True, env=vagrant_env)
        if rc != 0:
            console.print("[bold red]vagrant up failed[/bold red]")
            return 1
        console.print("  [green]VMs created and booted[/green]")

    # Health check: probe core VMs + extension VMs if selected
    console.print("  Health check — probing all VMs...")
    extra = {name: (ip, port) for ext_name, (name, ip, port) in EXTRA_VMS.items()
             if extensions and ext_name in extensions} if extensions else None
    hc = _health_check(vm_dir, extra_vms=extra)
    failed = [n for n, ok in hc.items() if not ok]
    if failed:
        console.print(f"  [red]{len(failed)} VMs unreachable: {', '.join(failed)}[/red]")
        return 1
    console.print(f"  [green]{len(hc)}/{len(hc)} VMs reachable[/green]")

    # Phase 2: Locate provisioning VM
    phase = "Phase 2/3 — Locating PROVISIONING VM"
    if HAS_RICH:
        console.print(f"\n[bold blue]{phase}[/bold blue]")
    else:
        print(f"\n[*] {phase}")

    key_path = find_provisioning_key(str(vm_dir))
    if not key_path:
        console.print("[yellow]No private key found, using password auth[/yellow]")
        ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=NUL"]
    else:
        console.print(f"  Key: {key_path}")
        ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=NUL", "-i", str(key_path)]

    prov_ip = get_provisioning_ip(str(vm_dir))
    if not prov_ip:
        eprint("Could not get PROVISIONING IP")
        return 1
    console.print(f"  IP: {prov_ip}")

    prov_user = "vagrant"

    # Phase 3: SCP + Ansible
    phase = "Phase 3/3 — Running Ansible Playbooks"
    if HAS_RICH:
        console.print(f"\n[bold blue]{phase}[/bold blue]")
    else:
        print(f"\n[*] {phase}")

    console.print("[*] Copying Ansible to PROVISIONING VM...")
    r = run(
        ["scp"] + ssh_opts + ["-r", str(ANSIBLE_DIR), f"{prov_user}@{prov_ip}:/home/vagrant/ansible"],
        timeout=120,
    )
    if r.returncode != 0:
        eprint(f"SCP failed:\n{r.stderr}")
        return 1

    console.print("[*] Copying config.json to PROVISIONING VM...")
    r = run(
        ["scp"] + ssh_opts + [str(CONFIG_PATH), f"{prov_user}@{prov_ip}:/home/vagrant/ansible/config.json"],
        timeout=30,
    )
    if r.returncode != 0:
        eprint(f"SCP config failed:\n{r.stderr}")
        return 1

    # Install galaxy collections
    console.print("[*] Installing Ansible collections (pinned versions)...")
    if verbose >= 3:
        cmd = "cd /home/vagrant/ansible && ansible-galaxy collection install -r requirements.yml --force"
    else:
        cmd = "cd /home/vagrant/ansible && ansible-galaxy collection install -r requirements.yml --force 2>&1 | grep -v '^Starting\\|^Process\\|^Installing'"
    rc = run_stream(
        ["ssh"] + ssh_opts + [f"{prov_user}@{prov_ip}", cmd],
        timeout=300,
        verbose=verbose,
    )
    if rc != 0:
        eprint("Ansible collection install failed")
        return 1

    # Run phases sequentially
    console.print("\n[dim]Running playbook phases...[/dim]")
    for phase_id, phase_path, phase_label, max_plays in PHASES:
        if phase_id in EXT_PHASE_IDS:
            continue  # extension playbooks run via the -e selection loop below, only if selected
        if from_phase and PHASE_NAMES.index(phase_id) < PHASE_NAMES.index(from_phase):
            console.print(f"[dim]  Skipping {phase_label} (--from-phase {from_phase})[/dim]")
            continue
        console.print(f"\n[bold blue]{phase_label}[/bold blue]")
        rc = _run_ansible_with_progress(ssh_opts, prov_user, prov_ip, phase_path, tracker, verbose, phase_name=phase_id, max_plays=max_plays)
        if rc != 0:
            eprint(f"[bold red]{phase_label} FAILED[/bold red]")
            console.print(f"[yellow]Resume from this phase: python cadre.py install --from-phase {phase_id}[/yellow]")
            return 1

    # Install extensions
    if extensions:
        for ext in extensions:
            rc = cmd_install_extension(ext, verbose=verbose, ssh_opts=ssh_opts,
                                       prov_user=prov_user, prov_ip=prov_ip)
            if rc != 0:
                return rc

    elapsed = _time() - start_time
    console.print(f"\n[bold green]Deployment complete in {timedelta(seconds=int(elapsed))}[/bold green]")

    # Final summary
    if HAS_RICH:
        console.print(Rule("Deployment Summary", style="bold cyan"))
        if tracker.plays:
            console.print(tracker.summary_table())
            console.print()
        console.print(tracker.final_summary())
    else:
        print(f"\n=== Deployment Summary ===")
        for p in tracker.plays:
            print(f"  {p.name}: {p.ok} ok, {p.changed} changed, {p.failed} failed, {p.skipped} skipped ({timedelta(seconds=int(p.duration))})")
        print(f"\n  Total: {tracker.total_tasks_all} tasks, {tracker.total_changed} changed, {tracker.total_failed} failed")

    return 0


EXT_PLAYBOOKS = {
    "elk-fleet": "playbooks/12-elk-fleet.yml",
    "net-monitor": "playbooks/13-net-monitor.yml",
    "velociraptor": "playbooks/14-velociraptor.yml",
}

def cmd_install_extension(ext_name, verbose=0, ssh_opts=None, prov_user=None, prov_ip=None):
    """Install a single extension playbook."""
    playbook = EXT_PLAYBOOKS.get(ext_name)
    if not playbook:
        eprint(f"Unknown extension: {ext_name}")
        eprint(f"Available: {list(EXT_PLAYBOOKS.keys())}")
        return 1

    console.print(f"\n[bold blue]Extension: {ext_name} ({playbook})[/bold blue]")

    if not ssh_opts or not prov_user or not prov_ip:
        key_path = find_provisioning_key()
        prov_ip = get_provisioning_ip()
        if not key_path or not prov_ip:
            eprint("Cannot find PROVISIONING VM")
            return 1
        prov_user = "vagrant"
        ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=NUL", "-i", str(key_path)]

    # No SCP needed — ansible dir already on provisioning VM from the phase run.
    # Extension playbooks (12/13/14) are self-contained: ES/Kibana templates are
    # inlined and VR artifacts/hunts live under ansible/files/. No extensions/ dir.
    rc = run_stream(
        ["ssh"] + ssh_opts + [f"{prov_user}@{prov_ip}",
         f"cd /home/vagrant/ansible && ansible-playbook -i inventories/hosts {playbook}"],
        timeout=7200,
        verbose=verbose,
    )
    if rc != 0:
        eprint(f"Ansible for {ext_name} failed (playbook: {playbook})")
        return 1

    console.print(f"[green]+[/green] Extension {ext_name} installed")
    return 0


INSTALL_FOLDER_NAME = "CADRE"  # Always created inside whatever parent the user picks


def _resolve_install_dir(user_path):
    """Treat user-supplied path as the PARENT and always nest a CADRE/ folder.

    Examples:
      D:\\VMs              -> D:\\VMs\\CADRE
      D:\\VMs\\CADRE        -> D:\\VMs\\CADRE     (already correct, no double-nest)
      D:\\Other            -> D:\\Other\\CADRE
    """
    p = Path(user_path).expanduser().resolve()
    if p.name == INSTALL_FOLDER_NAME:
        return p
    return p / INSTALL_FOLDER_NAME


def _get_vm_dir(vm_dir=None):
    """Get install directory: explicit arg > prompt with default. Always nests CADRE/."""
    if vm_dir:
        return _resolve_install_dir(vm_dir)
    default_parent = Path(_environ.get("USERPROFILE") or Path.home()) / "VMs"
    default = _resolve_install_dir(str(default_parent))
    try:
        if not sys.stdin.isatty():
            return default
        result = Prompt.ask(
            f"Parent directory (a '{INSTALL_FOLDER_NAME}' folder will be created inside)",
            default=str(default_parent),
        )
        return _resolve_install_dir(result)
    except (EOFError, OSError):
        return default


def _show_install_summary(vm_dir, extensions, verbose):
    """Render a Rich panel summarizing all settings; return True if user confirms."""
    ext_list = extensions or []
    v_labels = {0: "Progress bar only", 1: "Summary + key events",
                2: "Task names (recommended)", 3: "Full raw Ansible output"}

    table = Table(show_header=False, box=None, padding=(0, 2))
    table.add_column("Setting", style="bold cyan", width=22)
    table.add_column("Value", style="white")

    parent = vm_dir.parent if vm_dir.name == INSTALL_FOLDER_NAME else vm_dir
    table.add_row("Install location",  f"{vm_dir}")
    table.add_row("Parent directory",  f"{parent}")
    table.add_row("CADRE folder",      f"{vm_dir.name}/  ({'exists' if vm_dir.exists() else 'will be created'})")
    table.add_row("Vagrantfile source", f"{PROVIDER_DIR / 'Vagrantfile'}")
    table.add_row("Config source",     f"{CONFIG_PATH}")
    table.add_row("VMs to provision", f"7 core + {len(ext_list)} extension VM(s)" + (f" ({', '.join(EXTRA_VMS[e][0] for e in ext_list if e in EXTRA_VMS)})" if ext_list else ""))
    table.add_row("Extensions",        ", ".join(ext_list) if ext_list else "[dim]none[/dim]")
    table.add_row("Verbosity",         f"-{'v' * verbose} ({v_labels.get(verbose, str(verbose))})" if verbose else "0 (default — progress bar only)")
    table.add_row("Estimated time",    "2-3 h first run (box downloads ~10 GB) · 30-60 min subsequent")
    table.add_row("RAM needed",        "~44 GB (close other VMs if tight)")
    table.add_row("Disk needed",       "~150 GB free on target drive")

    console.print()
    console.print(Panel(table, title="[bold cyan]Deployment Configuration[/bold cyan]",
                        subtitle="[dim]Confirm to proceed[/dim]", border_style="cyan"))
    console.print()
    return Confirm.ask("Proceed with these settings?", default=True)


def _prompt_extensions():
    """Interactive extension selection. Returns list of extension names."""
    ext_list = ["elk-fleet", "net-monitor", "velociraptor"]
    ext_desc = {
        "elk-fleet": "Elasticsearch + Kibana + Fleet Server + Elastic Defend — centralized logging, detection rules, dashboards",
        "net-monitor": "Zeek + Suricata + Arkime + tcpdump + SiLK — network traffic analysis and PCAP",
        "velociraptor": "Velociraptor Server + MCP + Hunt Collections — endpoint detection and response",
    }

    console.print("\n[bold]Extensions[/bold] — add-on telemetry stacks deployed after base VMs are up:")
    for ext in ext_list:
        console.print(f"  [cyan]{ext}[/cyan]: {ext_desc[ext]}")

    install_all = Confirm.ask("\nInstall all extensions?", default=True)
    if install_all:
        return ext_list

    selected = []
    for ext in ext_list:
        if Confirm.ask(f"  Install {ext}?", default=True):
            selected.append(ext)
    return selected


def _prompt_verbosity():
    """Interactive verbosity level selection. Returns int 0-3."""
    console.print("\n[bold]Output verbosity[/bold] — controls how much Ansible output you see during deploy:")
    console.print("  [cyan]0[/cyan] — Progress bar only (cleanest)")
    console.print("  [cyan]1[/cyan] — Summary + key events")
    console.print("  [cyan]2[/cyan] — Task names as they execute ([green]recommended[/green])")
    console.print("  [cyan]3[/cyan] — Full raw Ansible output (debugging)")

    choice = Prompt.ask("Verbosity level", choices=["0", "1", "2", "3"], default="2")
    return int(choice)


def _ensure_vm_dir(vm_dir):
    """Ensure VM dir exists and has source files.

    Write-if-missing only: never overwrite an existing Vagrantfile or
    config.json in the runtime directory. Operators may edit the deployed
    copy (e.g. to tweak vagrant settings) and those edits must survive.
    To re-sync from the lab/ template, delete the file in vm_dir first.
    """
    vm_dir.mkdir(parents=True, exist_ok=True)
    vf = vm_dir / "Vagrantfile"
    cfg = vm_dir / "config.json"
    if not vf.exists():
        vf.write_text((PROVIDER_DIR / "Vagrantfile").read_text())
    if not cfg.exists():
        cfg.write_text(CONFIG_PATH.read_text())


def cmd_status(vm_dir=None):
    d = _get_vm_dir(vm_dir)
    _ensure_vm_dir(d)
    r = run_vagrant(["status"], cwd=str(d))
    print(r.stdout)
    return r.returncode


def cmd_start(vm_dir=None):
    d = _get_vm_dir(vm_dir)
    _ensure_vm_dir(d)

    if not _existing_vms(d):
        console.print("[yellow]No provisioned VMs found — running vagrant up (first-time setup)...[/yellow]")
        r = run_vagrant(["up"], cwd=str(d))
        return r.returncode

    console.print(f"[bold blue]Powering on {d.name} VMs via vmrun...[/bold blue]")
    ok, fail = _vmrun_start_all(d, callback=lambda line: console.print(line))
    if fail:
        console.print(f"[red]{fail} VM(s) failed to start[/red]")
        return 1

    console.print(f"[green]{ok}/{ok+fail} VMs powered on in ~{ok*2}s[/green]")

    console.print("[bold blue]Health check — waiting for WinRM/SSH...[/bold blue]")
    results = _health_check(d, callback=lambda line: None)
    ready = sum(1 for v in results.values() if v)
    down = [n for n, v in results.items() if not v]
    for n, v in results.items():
        icon = "[green]+[/green]" if v else "[red]-[/red]"
        console.print(f"  {icon} {n}")
    if down:
        console.print(f"[yellow]{len(down)} VMs not responding: {', '.join(down)}[/yellow]")
    console.print(f"[green]{ready}/{len(results)} VMs healthy[/green]")
    return 0 if not down else 1


def cmd_stop(vm_dir=None):
    d = _get_vm_dir(vm_dir)
    if not _existing_vms(d):
        console.print("[yellow]No VMs found in this directory.[/yellow]")
        return 0
    console.print("[bold blue]Stopping VMs via vmrun...[/bold blue]")
    ok = fail = 0
    for name, vmx in _find_vmx_files(d):
        rc = run([VMRUN_PATH, "-T", "ws", "stop", vmx]).returncode if VMRUN_PATH else -1
        if rc == 0:
            ok += 1
            console.print(f"  [green]-[/green] {name}")
        else:
            fail += 1
            console.print(f"  [red]-[/red] {name} (failed)")
    console.print(f"[green]{ok}/{ok+fail} VMs stopped[/green]")
    return 0 if not fail else 1


def cmd_destroy(vm_dir=None):
    d = _get_vm_dir(vm_dir)
    r = run_vagrant(["destroy", "-f"], cwd=str(d))
    if r.returncode != 0:
        eprint(r.stderr)
    return r.returncode


# ---------------------------------------------------------------------------
# Interactive Menu
# ---------------------------------------------------------------------------

def show_menu():
    """Show the interactive menu."""
    if not HAS_RICH:
        console.print("[yellow]Rich not installed. Run: pip install rich[/yellow]")
        console.print("Falling back to CLI mode.\n")
        return

    vm_dir = None

    while True:
        console.clear()
        console.print(Panel(
            "[bold cyan]CADRE v0.3[/bold cyan] — Cloud · Agentic · DFIR · Red-team · Environment\n"
            "11 VMs · 3 Domains · 8 Certifications · Server 2025",
            border_style="cyan",
        ))
        if vm_dir:
            console.print(f"\n[dim]VM directory: {vm_dir}[/dim]")

        console.print("\n[bold]Main Menu:[/bold]\n")
        console.print("  [1] Pre-flight Check")
        console.print("  [2] Quick Install (all VMs + all extensions + recommended settings)")
        console.print("  [3] Custom Install (choose extensions + verbosity)")
        console.print("  [4] Start VMs")
        console.print("  [5] Stop VMs")
        console.print("  [6] VM Status")
        console.print("  [7] Destroy Lab")
        console.print("  [8] Install Extensions")
        console.print("  [9] Set VM Directory")
        console.print("  [10] Help")
        console.print("  [q] Quit\n")

        choice = Prompt.ask("Select an option", choices=["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "q"], default="1")

        if choice == "1":
            cmd_check()
            Prompt.ask("\nPress Enter to continue")

        elif choice == "2":
            exts = ["elk-fleet", "net-monitor", "velociraptor"]
            cmd_install(extensions=exts, verbose=2, vm_dir=vm_dir)
            Prompt.ask("\nPress Enter to continue")

        elif choice == "3":
            cmd_install(vm_dir=vm_dir)
            Prompt.ask("\nPress Enter to continue")

        elif choice == "4":
            cmd_start(vm_dir=vm_dir)
            Prompt.ask("\nPress Enter to continue")

        elif choice == "5":
            cmd_stop(vm_dir=vm_dir)
            Prompt.ask("\nPress Enter to continue")

        elif choice == "6":
            cmd_status(vm_dir=vm_dir)
            Prompt.ask("\nPress Enter to continue")

        elif choice == "7":
            if Confirm.ask("Destroy ALL VMs? This cannot be undone.", default=False):
                cmd_destroy(vm_dir=vm_dir)
            else:
                console.print("[dim]Cancelled.[/dim]")
            Prompt.ask("\nPress Enter to continue")

        elif choice == "8":
            run_extension_install()
            Prompt.ask("\nPress Enter to continue")

        elif choice == "9":
            vm_dir = _get_vm_dir()
            console.print(f"[green]VM directory set to: {vm_dir}[/green]")
            Prompt.ask("\nPress Enter to continue")

        elif choice == "10":
            show_help()
            Prompt.ask("\nPress Enter to continue")

        elif choice == "q":
            console.print("[dim]Goodbye.[/dim]")
            sys.exit(0)


def run_extension_install():
    """Interactive extension installation."""
    console.print(Rule("Install Extensions", style="bold cyan"))

    ext_list = ["elk-fleet", "net-monitor", "velociraptor"]
    ext_desc = {
        "elk-fleet": "Elasticsearch + Kibana + Fleet Server + Elastic Defend",
        "net-monitor": "Zeek + Suricata + Arkime + tcpdump + SiLK",
        "velociraptor": "Velociraptor Server + MCP + Hunt Collections",
    }

    console.print("Select extensions to install:\n")
    selected = []
    for ext in ext_list:
        if Confirm.ask(f"  {ext} — {ext_desc[ext]}", default=True):
            selected.append(ext)

    if not selected:
        console.print("[dim]No extensions selected.[/dim]")
        return

    verbose = Confirm.ask("Show verbose output?", default=True)
    v = 2 if verbose else 0

    # Bring up the extension VM(s) first — they're gated in the Vagrantfile by
    # CADRE_EXTENSIONS. `vagrant up` creates any missing extension VM and no-ops
    # the already-running core VMs. Then the playbook configures the new VM.
    vm_dir = _get_vm_dir()
    vagrant_env = dict(_environ)
    vagrant_env["CADRE_EXTENSIONS"] = ",".join(selected)
    ext_vm_names = {EXTRA_VMS[e][0] for e in selected if e in EXTRA_VMS}
    existing = {name for name, _ in _find_vmx_files(vm_dir)}
    to_create = ext_vm_names - existing
    if to_create:
        console.print(f"  Bringing up extension VM(s): {', '.join(sorted(to_create))} ...")
        rc = run_vagrant(["up"], cwd=str(vm_dir), verbose=v, stream=True,
                         env=vagrant_env, callback=lambda line: None)
        if rc != 0:
            console.print("[bold red]vagrant up for extension VM(s) failed[/bold red]")
            return
        console.print("  [green]Extension VM(s) up[/green]")

    for ext in selected:
        cmd_install_extension(ext, verbose=v)


def show_help():
    """Show help information."""
    console.print(Rule("CADRE Help", style="bold cyan"))

    console.print("\n[bold]Quick Start:[/bold]")
    console.print("  1. Run [1] Pre-flight Check to verify prerequisites")
    console.print("  2. Ensure SCCM and Cloud Sync agents are downloaded")
    console.print("  3. Run [2] Quick Install to deploy everything")
    console.print("  4. After deploy, run extensions via [8] if not selected during install")

    console.print("\n[bold]CLI Mode (non-interactive):[/bold]")
    console.print("  python cadre.py check                    — Pre-flight check")
    console.print("  python cadre.py install                  — Interactive install (prompts for all options)")
    console.print("  python cadre.py install -e elk-fleet     — Install with specific extension")
    console.print("  python cadre.py install -vv              — Install with task-level output")
    console.print("  python cadre.py install --vm-dir D:\\VMs  — Install into D:\\VMs\\CADRE")
    console.print("  python cadre.py install --from-phase 02-objects  — Resume from Phase 2")
    console.print("  python cadre.py status                   — VM status")
    console.print("  python cadre.py start                    — Start all VMs")
    console.print("  python cadre.py stop                     — Stop all VMs")
    console.print("  python cadre.py destroy                  — Destroy all VMs")

    console.print("\n[bold]Verbose Levels:[/bold]")
    console.print("  0 — Progress bar only (cleanest)")
    console.print("  -v           — Summary + key events")
    console.print("  -vv          — Task names as they execute (recommended)")
    console.print("  -vvv         — Full raw Ansible output")

    console.print("\n[bold]Extensions:[/bold]")
    console.print("  elk-fleet     — ELK stack + detection rules + dashboards")
    console.print("  net-monitor   — Zeek + Suricata + Arkime + tcpdump + SiLK")
    console.print("  velociraptor  — Velociraptor Server + MCP + Hunt Collections")
    console.print("")
    console.print("  All extensions are independent. net-monitor auto-enrolls")
    console.print("  into elk-fleet if it's running. To toggle enrollment,")
    console.print("  stop/start the elk VM and re-run: python cadre.py install -e net-monitor")

    console.print("\n[bold]Troubleshooting:[/bold]")
    console.print("  • VMware Utility not running: Start 'vagrant-vmware-utility' service")
    console.print("  • DNS issues (cross-domain resolution fails):")
    console.print("        ssh vagrant@<prov_ip> 'cd ansible && ansible-playbook -i inventories/hosts playbooks/fix-dns.yml'")
    console.print("  • SCP failed: Check PROVISIONING VM is running and SSH is accessible")
    console.print("  • Ansible collection missing: Run 'ansible-galaxy collection install -r requirements.yml'")
    console.print("  • VM stuck: Run 'vagrant halt' then 'vagrant up'")
    console.print("  • Disk space: Each VM uses 5-15 GB. Total ~80-120 GB for all 11 VMs")

    console.print("\n[bold]Documentation:[/bold]")
    console.print("  docs/deployment.md     — Full deployment guide")
    console.print("  docs/architecture.md   — Architecture overview")
    console.print("  docs/extensions.md     — Extension details")
    console.print("  docs/testing-recommendations.md — Verification steps")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    # CLI flags present (or --help) → argparse path; otherwise → interactive menu
    CLI_TRIGGERS = {"check", "install", "status", "start", "stop", "destroy", "--help", "-h"}
    if len(sys.argv) <= 1 or sys.argv[1] not in CLI_TRIGGERS:
        show_menu()
        return 0

    import argparse
    parser = argparse.ArgumentParser(
        description="CADRE — Cloud Agentic DFIR Red-team Environment",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "action",
        nargs="?",
        choices=["check", "install", "status", "start", "stop", "destroy"],
        help="Action to perform",
    )
    parser.add_argument(
        "--install-extension", "-e",
        type=str, action="append", dest="extensions",
        help="Install a detachable extension (repeatable: -e elk-fleet -e net-monitor)",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="count", default=None,
        help="Verbosity: -v summary, -vv task names, -vvv full raw Ansible output",
    )
    parser.add_argument(
        "--vm-dir",
        type=str,
        help="Parent directory for the install. A 'CADRE' subfolder is always created inside (default: %%USERPROFILE%%\\VMs; final path becomes %%USERPROFILE%%\\VMs\\CADRE). Prompted if absent.",
    )
    parser.add_argument(
        "--yes", "-y",
        action="store_true",
        help="Skip all prompts, use defaults (VM dir=%%USERPROFILE%%\\VMs\\CADRE, extensions=all, verbosity=-vv)",
    )
    parser.add_argument(
        "--from-phase",
        type=str, choices=PHASE_NAMES,
        help="Skip completed phases and start from this phase: " + ", ".join(PHASE_NAMES),
    )
    args = parser.parse_args()

    if not args.action:
        show_menu()
        return 0

    default_vm = str(Path(_environ.get("USERPROFILE") or Path.home()) / "VMs" / "CADRE")
    dispatch = {
        "check":   lambda: cmd_check(verbose=args.verbose),
        "install": lambda: cmd_install(verbose=args.verbose, extensions=args.extensions, vm_dir=args.vm_dir or default_vm, auto_approve=args.yes, from_phase=args.from_phase),
        "status":  lambda: cmd_status(vm_dir=args.vm_dir or default_vm),
        "start":   lambda: cmd_start(vm_dir=args.vm_dir or default_vm),
        "stop":    lambda: cmd_stop(vm_dir=args.vm_dir or default_vm),
        "destroy": lambda: cmd_destroy(vm_dir=args.vm_dir or default_vm),
    }
    return dispatch[args.action]()


if __name__ == "__main__":
    sys.exit(main())
