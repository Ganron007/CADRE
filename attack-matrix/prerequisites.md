# Prerequisites — Before You Start

Read this once before attempting any walkthrough or campaign.

## 1. Lab deployed and running

All 7 core VMs (+ extensions) up and verified. See [`docs/deployment.md`](../docs/deployment.md). Quick check:

```powershell
python cadre.py status        # all VMs running
```

## 2. An attacker host (user-managed)

CADRE does **not** ship a Kali/attack VM — bring your own (Kali, Parrot, or Windows) attached to `vmnet2` (`192.168.77.0/24`). Tools per walkthrough are listed in [`Campaign/attack-tools-required.md`](Campaign/attack-tools-required.md).

For initial access attacks (WT063–WT068), you will host payloads on Kali's HTTP server. For post-exploitation (WT082 LSASS dump), you will bring `procdump.exe`.

## 3. Network + Kerberos setup

Do the one-time recon + Kerberos configuration in **[`01-walkthroughs/00-initial-access.md`](01-walkthroughs/00-initial-access.md)** — `/etc/hosts`, `/etc/krb5.conf`, and a TGT verification. Every other walkthrough assumes this is done.

## 4. Windows Defender disabled

Windows Defender real-time monitoring is **disabled** on all 5 Windows VMs (Tamper Protection=0, DisableAntiSpyware=1, WinDefend service=Stopped). This is required for credential access attacks (WT082 LSASS dump), initial access payload execution (WT063–WT068), and tool transfers. Without this, many attacks would be blocked.

## 5. Credentials

Walkthroughs list their starting credential in the Metadata table. The full user/password/group manifest lives internally at `docs/internal/_canonical/naming-scheme.md`. Most chains begin from **no creds** (WT000 recon → WT003 AS-REP / WT031 spray) and escalate.

Key credentials in the main campaign chain:
- `intern.blue` / `1nt3rn_Blu3!` (child.cadre.local — from AS-REP roasting)
- `svc.mssql` / `s3rv1c3_MSSQL!` (child.cadre.local — from Kerberoasting)
- `chief.command` / `C0mm@nd_Ch1ef!` (cadre.local — Domain Admin)
- `svc.sccm` / `s3rv1c3_SCCM!` (range.local — SCCM Full Admin)
- `svc.naa` / `N@A_s3rv1c3!` (range.local — Domain Admin)

## 6. A clean baseline (recommended)

Snapshot the lab clean before attacking so you can revert between walkthroughs. Reset/cycle workflow: [`docs/forensic-workflow.md`](../docs/forensic-workflow.md).

## Notes

- Attack numbering starts at **WT#002** (Kerberoasting begins with AES — RC4 is non-viable on Server 2025).
- Attacks are **telemetry exercises** — each walkthrough's "Telemetry Verification" section tells you which Elastic index / detection rule / EID to check after running it.
- The full campaign is documented in **[`Campaign/CAMPAIGNS.md`](Campaign/CAMPAIGNS.md)** — identity-driven, credential-earned, detection-verified.
