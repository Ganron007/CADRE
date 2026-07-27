# CADRE — Attack Automation Scripts

Reproducible attack scripts for each walkthrough and campaign. Run from attack VM against the CADRE substrate.

## Structure

```
04-automation/
├── linux/
│   ├── attacks/          Core AD bash scripts (WT002–WT062)
│   └── lib/
│       └── cadre-env.sh  Environment variables (IPs, creds, domains)
├── windows/
│   ├── attacks/          Core AD PowerShell scripts (WT002–WT062)
│   └── lib/
│       └── cadre-env.ps1 Environment variables
├── campaign-e/           Network defense exercises (WT069–WT081, 13 scripts)
├── campaign-g/           Post-exploitation attacks (WT082–WT093, 12 scripts)
├── campaign-h/           Initial access payloads (WT063–WT068, 6 scripts)
└── README.md             This file
```

## Usage

```bash
# From attack VM (Kali):
cd /opt/cadre/attack-matrix/04-automation/linux
source lib/cadre-env.sh
bash attacks/WT002-kerberoasting-aes.sh
```

```powershell
# From a Windows VM:
cd C:\cadre\attack-matrix\04-automation\windows
. .\lib\cadre-env.ps1
.\attacks\WT002-kerberoasting.ps1
```

## Convention

- Script name matches walkthrough number: `WT002-kerberoasting-aes.sh`
- Every script sources `lib/cadre-env.sh` first
- Campaign scripts (e/g/h) are standalone — source cadre-env from their directory
- Scripts are idempotent where possible (re-runnable without side effects)
- Output goes to stdout — pipe to file for evidence archive

## Status

| Directory | Scripts | Purpose |
|:----------|:------:|:--------|
| `linux/attacks/` | 77 | Core AD bash (cross-platform) |
| `windows/attacks/` | 12 | Core AD PowerShell |
| `campaign-e/` | 13 | Network defense exercises |
| `campaign-g/` | 12 | Post-exploitation |
| `campaign-h/` | 6 | Initial access |
| **Total** | **120** | — |
