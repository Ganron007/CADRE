# CADRE — Attack Automation Scripts

Reproducible attack scripts for each walkthrough. Run from attack VM against the CADRE substrate.

## Structure

```
04-automation/
├── linux/
│   ├── attacks/          Per-walkthrough bash scripts
│   └── lib/
│       └── cadre-env.sh  Environment variables (IPs, creds, domains)
├── windows/
│   ├── attacks/          Per-walkthrough PowerShell scripts
│   └── lib/
│       └── cadre-env.ps1 Environment variables
└── README.md             This file
```

## Usage

```bash
# From attack VM (kali — Plan 1):
cd /opt/cadre/attack-matrix/04-automation/linux
source lib/cadre-env.sh
bash attacks/WT002-kerberoasting-aes.sh
```

```powershell
# From a Windows VM (if needed):
cd C:\cadre\attack-matrix\04-automation\windows
. .\lib\cadre-env.ps1
.\attacks\WT002-kerberoasting.ps1
```

## Convention

- Script name matches walkthrough number: `WT002-kerberoasting-aes.sh`
- Every script sources `lib/cadre-env.sh` first
- Scripts are idempotent where possible (re-runnable without side effects)
- Output goes to stdout — pipe to file for evidence archive

## Status

**Complete** — 59 Linux bash scripts + 2 env libs + 2 common libs. Windows PowerShell scripts deferred (most Linux-bash scripts cover the cross-platform tooling). Scripts marked `BROKEN` where CA service or other infra is not running.
