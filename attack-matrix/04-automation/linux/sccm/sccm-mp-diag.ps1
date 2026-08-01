# MP-side + transport diagnostics on mbr02 — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$siteLogs = 'C:\Program Files\Microsoft Configuration Manager\Logs'
$clientLogs = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== CcmMessaging.log: transport/location lines ==='
if (Test-Path "$clientLogs\CcmMessaging.log") {
  Get-Content "$clientLogs\CcmMessaging.log" -Tail 400 | Where-Object { $_ -match 'Location|request|Request|http|HTTP|Failed|error|Error|503|500|403|401|httpsync|sync|Sending message|POST' } | Select-Object -Last 30 | ForEach-Object {
    if ($_ -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ }
  }
} else { Write-Output '  no CcmMessaging.log' }

Write-Output '=== MP_LocationManager.log tail (site side) ==='
$ml = "$siteLogs\MP_LocationManager.log"
if (Test-Path $ml) { Get-Content $ml -Tail 30 | ForEach-Object { Write-Output $_ } } else { Write-Output '  (no MP_LocationManager.log)' }

Write-Output '=== MP_PolicyManager.log tail (site side) ==='
$pl = "$siteLogs\MP_PolicyManager.log"
if (Test-Path $pl) { Get-Content $pl -Tail 30 | ForEach-Object { Write-Output $_ } } else { Write-Output '  (no MP_PolicyManager.log)' }

Write-Output '=== Client HTTP/HTTPS registry state ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCM\CCMHttpsState=" + $cp.CCMHttpsState)
Write-Output ("  CCM\CCMHttpPort=" + $cp.CCMHttpPort)
Write-Output ("  CCM\CCMHttpsPort=" + $cp.CCMHttpsPort)
Write-Output ("  CCM\CCMCERTID=" + $cp.CCMCERTID)
Write-Output '  --- MY store client-auth certs (LocalMachine) ---'
Get-ChildItem 'Cert:\LocalMachine\My' -ErrorAction SilentlyContinue | Where-Object { $_.EnhancedKeyUsageList -match 'Client Authentication' } | Select-Object -First 5 | ForEach-Object { Write-Output ("  CERT: " + $_.Subject + " | " + $_.NotAfter) }
Write-Output 'MPDIAG_DONE'
