# Definitively check if SMSSITECODE reached the MSI in the 18:24 fresh install — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== ccmsetup.log: ALL MSI PROPERTIES lines (18:2x) ==='
Get-Content 'C:\Windows\ccmsetup\Logs\ccmsetup.log' | Where-Object { $_ -match 'MSI PROPERTIES|Expanded MSI PROPERTIES|Properties:' } | Select-Object -Last 6 | ForEach-Object {
  if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) }
}

Write-Output '=== ccmsetup.log: SMSSITECODE/SMSMP/RESETKEY mentions (18:2x) ==='
Get-Content 'C:\Windows\ccmsetup\Logs\ccmsetup.log' | Where-Object { $_ -match '18:2[4-5]' -and $_ -match 'SMSSITECODE|SMSMP|RESETKEY|Invalid argument|Property' } | Select-Object -Last 15 | ForEach-Object {
  if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) }
}

Write-Output '=== client.msi.log: SMSSITECODE / SMSMP / Property lines ==='
$ml = 'C:\Windows\ccmsetup\Logs\client.msi.log'
if (Test-Path $ml) {
  Get-Content $ml | Where-Object { $_ -match 'SMSSITECODE|SMSMP|RESETKEY|CommandLine|Property\(S\): SMSSITECODE|Property\(S\): SMSMP' } | Select-Object -Last 20 | ForEach-Object { Write-Output ("  " + $_.Trim()) }
} else { Write-Output '  (no client.msi.log - check path)' }

Write-Output '=== SmsSetClientConfig WMI result check - current Mobile Client key values ==='
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
if (Test-Path $mc) {
  Get-ItemProperty $mc -ErrorAction SilentlyContinue | Format-List | Out-String -Width 200 | ForEach-Object { $_.Split("`n") | Where-Object { $_ -match 'Site|SMS|MP|Client' } | ForEach-Object { Write-Output ("  " + $_.Trim()) } }
} else { Write-Output '  SMS\Mobile Client absent' }
Write-Output 'PROPSCHECK_DONE'
