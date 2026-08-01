$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Remove-Item C:\Tools\cadre-attack\*esc4-check*.json -ErrorAction SilentlyContinue
& $certpy template -template CADRE-ESC4 -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -save-configuration C:\Tools\cadre-attack\esc4-check.json 2>&1 | Select-Object -Last 3
$jf = Get-ChildItem C:\Tools\cadre-attack\*esc4-check*.json -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if ($jf) {
  $j = Get-Content $jf -Raw | ConvertFrom-Json
  Write-Output "NAME_FLAG=$($j.'msPKI-Certificate-Name-Flag')"
  Write-Output "EKU=$($j.'pKIExtendedKeyUsage')"
  if ($j.'msPKI-Certificate-Name-Flag' -eq 1) { Write-Output "STATE=ESC1-MODIFIED (BAD)" } else { Write-Output "STATE=RESTORED-ORIGINAL" }
} else { Write-Output "NO_CHECK_JSON" }
Write-Output "DONE"
