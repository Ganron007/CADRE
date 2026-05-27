# CADRE — Testing Recommendations

Run these checks before and during deployment to catch issues early. Ordered from cheapest (static analysis, no VMs) to most expensive (full deploy + telemetry verification).

---

## Stage 0: Static Analysis (no VMs needed)

### 0.1 — YAML / JSON Validation

```powershell
# config.json
python -c "import json; json.load(open('lab/data/config.json')); print('config.json OK')"

# All Ansible playbooks
python -c "
import yaml, os
bad = []
for dirpath, dirs, files in os.walk('ansible'):
    for f in files:
        if f.endswith(('.yml', '.yaml')):
            fp = os.path.join(dirpath, f)
            try: yaml.safe_load(open(fp))
            except Exception as e: bad.append((fp, str(e)))
for dirpath, dirs, files in os.walk('extensions'):
    for f in files:
        if f.endswith(('.yml', '.yaml')):
            fp = os.path.join(dirpath, f)
            try: yaml.safe_load(open(fp))
            except Exception as e: bad.append((fp, str(e)))
print(f'{len(bad)} bad files' if bad else 'All YAML valid')
for b in bad: print(f'  {b[0]}: {b[1]}')
"
```

### 0.2 — Python Import Verification

```powershell
python -c "
import sys, json, subprocess, argparse
from pathlib import Path
print('Core imports OK')
"
```

### 0.3 — Config ↔ Vagrantfile ↔ Inventory Consistency

```powershell
python docs/internal/tools/deploy-harness/test_plan0.py
```

This runs the existing Plan 0 test harness which verifies:
- 7 VMs in Vagrantfile with correct IPs/RAM/CPUs
- config.json has 3 domains, correct users/groups/OUs
- Ansible inventory matches config.json IPs
- All playbooks have valid YAML syntax (32 files)
- Extensions have been archived — playbooks are self-contained in ansible/playbooks/
- No old ADOPT-era subnet references remain

### 0.4 — Ansible Syntax Check

Requires `ansible-playbook` installed (on provisioning VM or local):

```bash
ansible-playbook --syntax-check -i ansible/inventories/hosts ansible/playbooks.yml
# Extension playbooks are now self-contained in ansible/playbooks/ (files 12-14)
# ansible-playbook --syntax-check -i ansible/inventories/hosts ansible/playbooks/12-elk-fleet.yml
# ansible-playbook --syntax-check -i ansible/inventories/hosts ansible/playbooks/13-net-monitor.yml
# ansible-playbook --syntax-check -i ansible/inventories/hosts ansible/playbooks/14-velociraptor.yml
```

### 0.5 — URL Liveness (download dependencies reachable)

```powershell
python -c "
import urllib.request, ssl
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

urls = [
    'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
    'https://download.sysinternals.com/files/Sysmon.zip',
    'https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml',
    'https://github.com/arkime/arkime/releases/',
    'https://github.com/Velocidex/velociraptor/releases/',
    'https://download.opensuse.org/repositories/security:zeek/xUbuntu_24.04/Release.key',
    'https://tools.netsa.cert.org/releases/',
]
for url in urls:
    try:
        code = urllib.request.urlopen(url, timeout=10, context=ctx).getcode()
        status = 'OK' if code == 200 else f'HTTP {code}'
    except Exception as e:
        status = f'FAIL: {type(e).__name__}'
    print(f'  [{status}] {url[:60]}')
"
```

---

## Stage 1: Pre-Deploy (cadre.py check)

```powershell
python cadre.py check
```

Verifies:
- [x] Running as Administrator
- [x] RAM >= 36 GB
- [x] Disk >= 150 GB free
- [x] Vagrant installed
- [x] vagrant-vmware-utility service running
- [x] Plugins: vagrant-vmware-desktop, vagrant-reload
- [x] config.json loadable
- [x] Media files present (SCCM eval + Cloud Sync agent — SCCM already deployed)

---

## Stage 2: Post-Deploy Base Lab (Plan 0 Half A)

After `python cadre.py install` completes:

### 2.1 — VMs Running

```powershell
python cadre.py status
# All 7 core VMs should show "running" (extension VMs are created on demand via `cadre.py install -e <ext>`)
```

### 2.2 — Domain Health

```powershell
# RDP or WinRM to dc01:
nltest /dsgetdc:cadre.local              # Returns dc01
nltest /dsgetdc:child.cadre.local        # Returns dc02
nltest /domain_trusts                     # Shows child + range.local trusts

# DNS forwarders
nslookup dc03.range.local 192.168.77.10  # Should resolve to .12
nslookup dc01.cadre.local 192.168.77.12  # Should resolve to .10
```

### 2.3 — AD Objects

```powershell
# On dc01:
Get-ADUser -Filter * -SearchBase "DC=cadre,DC=local" | Measure-Object  # ~12 (10 users + 2 svc)
Get-ADGroup -Filter * -SearchBase "DC=cadre,DC=local" | Measure-Object # 9 groups
Get-ADOrganizationalUnit -Filter * -SearchBase "DC=cadre,DC=local" | Measure-Object  # 6 OUs
```

### 2.4 — Member Server Domain Join

```powershell
# On mbr01:
(Get-WmiObject Win32_ComputerSystem).Domain  # "child.cadre.local"

# On mbr02:
(Get-WmiObject Win32_ComputerSystem).Domain  # "range.local"
```

### 2.5 — Vulnerability Configuration

```powershell
# Kerberoasting target (on dc01):
Get-ADUser chief_command -Properties ServicePrincipalName | Select ServicePrincipalName
# Should show: HTTP/cadre-portal.cadre.local

# AS-REP (on dc02):
Get-ADUser intern_blue -Properties DoesNotRequirePreAuth | Select DoesNotRequirePreAuth
# Should show: True

# Unconstrained delegation:
Get-ADComputer mbr01 -Properties TrustedForDelegation | Select TrustedForDelegation
# Should show: True

# ADCS templates:
certutil -catemplates | findstr "CADRE-ESC"
# Should list: CADRE-ESC1, CADRE-ESC2, ... CADRE-ESC15
```

### 2.6 — MSSQL

```powershell
# From attack VM (user-managed Kali):
impacket-mssqlclient CHILD/analyst_t1:'T13r_An@lyst!'@192.168.77.22
# Should connect. Then: SELECT @@SERVERNAME
```

### 2.7 — Linux01

```bash
# SSH to linux01:
realm list                     # Should show cadre.local
systemctl is-active mssql-server  # active
exportfs -v                    # Should show /exports/secure-share with sec=krb5p
podman ps                      # Should show cadre-monitor container running
```

---

## Stage 3: Post-Deploy Half B (Telemetry Stack)

### 3.1 — Sysmon Running on All Windows VMs

```powershell
# On each of dc01, dc02, dc03, mbr01, mbr02:
Get-Service Sysmon64  # Status: Running
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1
# Should return an event (proves Sysmon is generating logs)
```

### 3.2 — Windows Audit Baseline (cadre-dfir-monitoring.ps1)

```powershell
# On any Windows VM — verifies cadre-dfir-monitoring.ps1 output:
auditpol /get /category:* | Select-String "Success and Failure" | Measure-Object
# Count should be >= 44

# PowerShell deep visibility
(Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging").EnableScriptBlockLogging  # 1
(Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames")."*"                # *

# 4688 cmdline + policy persistence + NTLM audit
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit").ProcessCreationIncludeCmdLine_Enabled  # 1
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").SCENoApplyLegacyAuditPolicy            # 1
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0").AuditReceivingNTLMTraffic       # 2

# Log sizes
(Get-WinEvent -ListLog Security).MaximumSizeInBytes                                       # 1073741824
(Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational").MaximumSizeInBytes         # 1073741824

# Server 2025-only channels exist + enabled
(Get-WinEvent -ListLog "Microsoft-Windows-Kerberos/Operational").IsEnabled                # True
(Get-WinEvent -ListLog "Microsoft-Windows-AMSI/Operational").IsEnabled                    # True
```

### 3.2.5 — Linux Audit Baseline (linux01)

```bash
# SSH to linux01 — verifies linux/tasks/auditd.yml output (spec: monitoring-dfir-specifications.md §2.6):
sudo systemctl is-active auditd                                       # active
sudo auditctl -l | wc -l                                              # >= 45 rules
sudo auditctl -s | grep enabled                                       # enabled 2  (immutable)
sudo systemctl is-active sssd                                         # active
sudo systemctl is-active podman-events-log                            # active
sudo grep -c "^" /etc/audit/rules.d/cadre.rules                       # > 60 lines

# MSSQL Linux audit enabled
sudo /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 's@_P@ssw0rd!L@b!' \
     -Q "SELECT name, is_state_enabled FROM sys.server_audits WHERE name='CADRE_Audit'"
# Should return: CADRE_Audit  1

ls /var/opt/mssql/audit/*.sqlaudit 2>/dev/null | wc -l                # >= 1
ls /var/log/podman-events.log                                         # exists
ls /var/log/sssd/sssd_cadre.local.log                                 # exists (debug_level=5)
```

### 3.3 — ELK-Fleet Extension

```bash
# Elasticsearch cluster health
curl -u elastic:$PASS http://192.168.77.50:9200/_cluster/health
# status: "green" or "yellow" (single-node)

# Fleet policies exist
curl -u elastic:$PASS http://192.168.77.50:5601/api/fleet/agent_policies | python -c "
import sys,json; d=json.load(sys.stdin); names=[p['name'] for p in d['items']]; print(names)"
# Should include: "CADRE-All", "CADRE-Linux", "CADRE-Monitor"

# Agents enrolled
curl -u elastic:$PASS http://192.168.77.50:5601/api/fleet/agents | python -c "
import sys,json; d=json.load(sys.stdin); print(f'{len(d[\"items\"])} agents online')"
# Should show: 6 or 7 agents

# Windows events flowing
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-system.security-*/_count"
# count > 100

# Sysmon flowing
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-windows.sysmon_operational-*/_count"
# count > 0

# Linux substrate flowing (linux01 only)
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-auditd.log-*/_count"        # > 0
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-mssql.audit-*/_count"       # > 0 after first MSSQL login
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-sssd-*/_count"              # > 0
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-podman-*/_count"            # > 0
# osquery configured on CADRE-Linux Fleet policy — check results
# curl -u elastic:$PASS "http://192.168.77.50:9200/logs-osquery_manager.result-*/_count"  # > 0

# Detection rules loaded
curl -u elastic:$PASS http://192.168.77.50:5601/api/detection_engine/rules/_find | python -c "
import sys,json; print(f'{json.load(sys.stdin)[\"total\"]} rules')"
# >= 7
```

### 3.4 — Net-Monitor Extension

```bash
# SSH to monitor:
sudo /opt/zeek/bin/zeekctl status          # All workers: running
sudo systemctl is-active suricata          # active
sudo systemctl is-active arkimecapture     # inactive (manual offline workflow)
sudo systemctl is-active arkimeviewer      # active
ls /opt/pcap/manual/                        # capture-*.pcap files after manual run
ls /opt/zeek/logs/current/                  # conn.log, dns.log, kerberos.log...

# Arkime web UI reachable
curl -k -u admin:arkime https://192.168.77.55:8005/api/sessions | python -c "
import sys,json; print(f'{json.load(sys.stdin)[\"recordsTotal\"]} sessions captured')"

# Zeek data in Elastic
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-zeek.*-*/_count"
# count > 0

# Suricata data in Elastic
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-suricata-*/_count"
# count > 0
```

### 3.5 — Velociraptor Extension

```bash
# Web GUI reachable
curl -k https://192.168.77.51:8889/ -o /dev/null -w "%{http_code}"
# 200

# All clients enrolled (5 Windows + 1 Linux = 6)
curl -k -u admin:VelociraptorDefault! \
  "https://192.168.77.51:8889/api/v1/SearchClients?query=*" | python -c "
import sys,json; d=json.load(sys.stdin); print(f'{len(d.get(\"items\",[]))} clients')"
# 6

# MCP endpoint healthy
curl http://192.168.77.51:8002/health
# {"status":"ok"}
```

---

## Stage 4: End-to-End Smoke Test (full cycle)

The ultimate verification: run one attack and confirm telemetry lands in EVERY data source.

```bash
# From attack VM — run Kerberoasting
impacket-GetUserSPNs cadre.local/analyst_dfir:'An@lyst_DF1R!' -dc-ip 192.168.77.10 -request

# Wait 60 seconds for propagation, then verify:

# 1. Windows Security Event 4769
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-system.security-*/_count?q=event.code:4769"
# count > 0

# 2. Sysmon process creation
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-windows.sysmon_operational-*/_count?q=event.code:1"
# count > 0

# 3. Zeek kerberos.log
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-zeek.*-*/_count?q=event.dataset:zeek.kerberos"
# count > 0

# 4. Arkime captured the session
curl -k -u admin:arkime "https://192.168.77.55:8005/api/sessions?expression=protocols==kerberos"
# recordsTotal > 0

# 5. Detection rule fired
curl -u elastic:$PASS "http://192.168.77.50:9200/.alerts-security.alerts-*/_count"
# count > 0 (Kerberoast detection rule)

# 6. Velociraptor can collect from dc01
# (trigger via web GUI or API — cadre-event-logs hunt)

# If ALL 6 pass → Plan 0 Windows + network telemetry are operational.
```

### Stage 4b — Linux-Substrate Attack Smoke Test

```bash
# From attack VM — read the MSSQL keytab on linux01 (simulates credential access from a domain user shell):
ssh chief_command@192.168.77.40 'sudo cat /var/opt/mssql/secrets/mssql.keytab > /dev/null'

# Privileged container escape probe inside the running cadre-monitor container:
ssh vagrant@192.168.77.40 'podman exec cadre-monitor nsenter -t 1 -m -p ls /'

# Wait 60 seconds, then verify each layer caught it:

# 1. auditd recorded keytab read (key=mssql_keytab)
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-auditd.log-*/_count?q=auditd.log.key:mssql_keytab"
# count > 0

# 2. auditd recorded container escape syscall (key=container_escape)
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-auditd.log-*/_count?q=auditd.log.key:container_escape"
# count > 0

# 3. SSSD logged the ssh PAM auth
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-sssd-*/_count?q=chief_command"
# count > 0

# 4. Podman events recorded the exec
curl -u elastic:$PASS "http://192.168.77.50:9200/logs-podman-*/_count?q=event.action:exec"
# count > 0

# 5. Detection rule L01 (keytab read) fired
curl -u elastic:$PASS "http://192.168.77.50:9200/.alerts-security.alerts-*/_count?q=kibana.alert.rule.name:*keytab*"
# count > 0

# If ALL 5 pass → Linux-substrate telemetry pipeline is operational.
```

---

## Stage 5: Export Pipeline Verification (Plan 2)

```bash
python docs/internal/tools/export-attack/export.py --attack T002 --start "<ts>" --end "<ts>"

# Verify bundle structure:
ls exports/T002-*/
# Should contain: 00-manifest.json + folders 01-11

# Validate manifest:
python -c "
import json
m = json.load(open('exports/T002-*/00-manifest.json'))
assert m['schema_version'] == 'dfir-nexus-evidence-1.0'
assert len(m['evidence_items']) >= 3
print('Manifest valid')
"
```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| WinRM timeout | VM not fully booted / WinRM not ready | Wait 2-3 min; run `install` again (Ansible is idempotent) |
| Vagrant box import fails | Outdated plugins / missing VMware utility | `vagrant plugin update`; verify `Get-Service vagrant-vmware-utility` is Running |
| Sysmon not running | Download URL changed / install failed | Check `C:\Tools\Sysmon\Sysmon64.exe` exists; re-run security role |
| Fleet agents offline | Fleet Server not reachable / cert issue | Check `https://192.168.77.50:8220` responds; agents use `--insecure` flag |
| Zeek/Suricata no data | Promiscuous NIC not configured | Verify VMX has `ethernet1.allowPromiscuous = TRUE` |
| Arkime empty sessions | Capture not on eth1 | Check `/opt/arkime/etc/config.ini` → `interface=eth1` |
| Velociraptor clients offline | Config mismatch / TLS cert | Re-generate client config; verify server is listening on 8000 |
| No 4769 events after Kerberoast | Audit policy not applied | Run `auditpol /get /subcategory:"Kerberos Service Ticket Operations"` — should show Success+Failure |
| ADCS templates missing | Manual install not done (templates are NOT auto-created — PSPKI can't create v1 templates on Server 2025) | Follow [adcs-configuration-guide.md](adcs-configuration-guide.md); verify with `certutil -catemplates`, then re-run `08-adcs-verify.yml` |
| MSSQL connection refused | Manual SQL install not done / service not started | See [sql-integration-guide.md](sql-integration-guide.md); check `Get-Service MSSQL$SQLEXPRESS` + firewall rule 1433 |
