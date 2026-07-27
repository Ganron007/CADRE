# WT#000 — Initial Access: Recon & Attack-Machine Setup

## Metadata

| Field | Value |
|-------|-------|
| **Target VMs** | All (network-wide discovery) |
| **Domains** | cadre.local · child.cadre.local · range.local |
| **Starting Credential** | None (no-cred recon) → one known user for Kerberos verify |
| **Tools Required** | netexec (nxc), nmap, krb5-user, impacket |
| **Certifications** | CRTP, OSCP+ (all — this is the front door) |
| **MITRE ATT&CK** | T1046 (Network Service Discovery), T1595 (Active Scanning) |
| **Difficulty** | Easy |

This is the entry point for the whole matrix. Every other walkthrough assumes you have done this once: mapped the network, configured Kerberos, and confirmed you can authenticate. Tools are **not** deployed by CADRE — bring your own (see [`../Campaign/attack-tools-required.md`](../Campaign/attack-tools-required.md)).

## Prerequisites

- An attacker host (Kali/Parrot/Windows — user-managed) on `vmnet2` `192.168.77.0/24`
- Network reachability to the lab (no segmentation inside the /24)

## Domain Reference

| Forest | Domain | DC | IP | NetBIOS |
|--------|--------|----|----|---------|
| Root | cadre.local | dc01 | .10 | CADRE |
| Child | child.cadre.local | dc02 | .11 | CHILD |
| External | range.local | dc03 | .12 | RANGE |

| Member / host | Domain | IP | Note |
|---------------|--------|----|------|
| mbr01 | child.cadre.local | .22 | MSSQL + IIS · SMB signing OFF (relay target) |
| mbr02 | range.local | .23 | SQL + WSUS + VSC + SCCM · SMB signing OFF (relay target) |
| linux01 | cadre.local | .40 | AD-joined Ubuntu (SSSD, MSSQL-on-Linux, NFS-krb5, Podman) |

## Attack Steps

### Step 1: NetBIOS discovery (no creds)

```bash
nxc smb 192.168.77.0/24
```

Expect 5 Windows hosts + linux01. Watch the `signing:` column:

| Finding | Implication |
|---------|-------------|
| 3 DCs (.10/.11/.12) `signing:True` | enforced — not relay targets |
| mbr01 (.22), mbr02 (.23) `signing:False` | **NTLM relay targets** (WT#021/022) |
| 3 domains across 2 forests | cadre.local + child = one forest; range.local = separate forest, bidirectional trust |
| all in one /24 | no segmentation — full lateral movement |

### Step 2: Confirm DCs via DNS SRV

```bash
nslookup -type=srv _ldap._tcp.dc._msdcs.cadre.local 192.168.77.10
nslookup -type=srv _ldap._tcp.dc._msdcs.child.cadre.local 192.168.77.11
nslookup -type=srv _ldap._tcp.dc._msdcs.range.local 192.168.77.12
```

### Step 3: Configure `/etc/hosts`

```bash
sudo tee -a /etc/hosts << 'EOF'
192.168.77.10   cadre.local dc01.cadre.local dc01
192.168.77.11   child.cadre.local dc02.child.cadre.local dc02
192.168.77.12   range.local dc03.range.local dc03
192.168.77.22   mbr01.child.cadre.local mbr01
192.168.77.23   mbr02.range.local mbr02
192.168.77.40   linux01.cadre.local linux01
EOF
```

### Step 4: Configure Kerberos (`/etc/krb5.conf`)

Realm names are **UPPERCASE**.

```ini
[libdefaults]
  default_realm = CADRE.LOCAL
  kdc_timesync = 1
  ccache_type = 4
  forwardable = true
  proxiable = true

[realms]
  CADRE.LOCAL        = { kdc = dc01.cadre.local        admin_server = dc01.cadre.local }
  CHILD.CADRE.LOCAL  = { kdc = dc02.child.cadre.local  admin_server = dc02.child.cadre.local }
  RANGE.LOCAL        = { kdc = dc03.range.local        admin_server = dc03.range.local }

[domain_realm]
  .cadre.local        = CADRE.LOCAL
  cadre.local         = CADRE.LOCAL
  .child.cadre.local  = CHILD.CADRE.LOCAL
  child.cadre.local   = CHILD.CADRE.LOCAL
  .range.local        = RANGE.LOCAL
  range.local         = RANGE.LOCAL
```

### Step 5: Verify Kerberos with a known user

Use any documented user (full manifest in `docs/internal/_canonical/naming-scheme.md`). The automation libs standardize on `analyst_dfir` as the low-priv enumeration account:

```bash
impacket-getTGT cadre.local/analyst_dfir:'An@lyst_DF1R!'
export KRB5CCNAME=$PWD/analyst_dfir.ccache
impacket-smbclient -k -no-pass @dc01.cadre.local   # 'shares' should list
unset KRB5CCNAME
```

A TGT + Kerberos SMB access confirms hosts/realm config are correct. (If RC4 errors appear, that's expected on Server 2025 — use AES.)

### Step 6: Full service scan

```bash
nmap -Pn -p- -sC -sV -oA cadre_full 192.168.77.10-12,22,23,40
```

Expect the AD service set (53/88/135/139/389/445/464/593/636/3268-9/3389/5985/9389) on DCs; **1433** on mbr01/mbr02/linux01; **443** ADCS Web Enrollment on dc01 (ESC8); **2049** NFS on linux01.

## Post-Exploitation Chain

- Relay targets (mbr01/mbr02 signing off) → **WT#021/022** (NTLM relay → RBCD / SYSTEM)
- ADCS HTTP endpoint on dc01 → **WT#056** (ESC8)
- No creds yet → **WT#003** (AS-REP roast `intern_blue`) or **WT#031** (password spray) for first foothold
- Have a low-priv user → **WT#002** (Kerberoast) → crack → escalate

## Telemetry Verification

| Source | What recon produces |
|--------|---------------------|
| **Zeek** (`logs-zeek.conn-*`, `dns-*`) | Mass connection fan-out across the /24; SRV lookups in `dns.log` |
| **Suricata** | Port-scan / ET-SCAN signatures on the nmap sweep |
| **Elastic** (`logs-system.security-*`) | 4768 (TGT request) from Step 5; 4624/4625 logon events from nxc |
| **Arkime** | Full PCAP of the scan if manual capture is running |

Recon is noisy by design — confirming it lights up Zeek/Suricata is itself a useful detection baseline.

## Status

ENTRY POINT — run once before any other walkthrough. No lab misconfig required.
