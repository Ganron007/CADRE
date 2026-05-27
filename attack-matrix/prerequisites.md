# Prerequisites — Before You Start

Read this once before attempting any walkthrough.

## 1. Lab deployed and running

All 7 core VMs (+ extensions) up and verified. See [`docs/deployment.md`](../docs/deployment.md). Quick check:

```powershell
python cadre.py status        # all VMs running
```

## 2. An attacker host (user-managed)

CADRE does **not** ship a Kali/attack VM — bring your own (Kali, Parrot, or Windows) attached to `vmnet2` (`192.168.77.0/24`). Tools per walkthrough are listed in [`attack-tools-required.md`](attack-tools-required.md).

## 3. Network + Kerberos setup

Do the one-time recon + Kerberos configuration in **[`01-walkthroughs/00-initial-access.md`](01-walkthroughs/00-initial-access.md)** — `/etc/hosts`, `/etc/krb5.conf`, and a TGT verification. Every other walkthrough assumes this is done.

## 4. Credentials

Walkthroughs list their starting credential in the Metadata table. The full user/password/group manifest lives internally at `docs/internal/_canonical/naming-scheme.md`. Most chains begin from **no creds** (WT#000 recon → WT#003 AS-REP / WT#031 spray) and escalate.

## 5. A clean baseline (recommended)

Snapshot the lab clean before attacking so you can revert between walkthroughs. Reset/cycle workflow: [`docs/forensic-workflow.md`](../docs/forensic-workflow.md).

## Notes

- Attack numbering starts at **WT#002** (Kerberoasting begins with AES — RC4 is non-viable on Server 2025).
- Attacks are **telemetry exercises** — each walkthrough's "Telemetry Verification" section tells you which Elastic index / detection rule / EID to check after running it.
