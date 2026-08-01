# Deep ConfigMgr client state on mbr02
$ErrorActionPreference = 'Continue'
Write-Output ('SVC_PATH=' + ((sc.exe qc CcmExec | Out-String) -replace "`r`n",' | '))
$ccmroot = Get-ChildItem 'C:\Windows\CCM*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
Write-Output ('CCM_FOLDERS=' + ($ccmroot -join ','))
Write-Output ('CCMSETUP_EXE=' + (Test-Path 'C:\Windows\CCMSetup'))
$ccmreg = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($ccmreg) { Write-Output ('CCMREG=' + $ccmreg.SiteCode + '|' + $ccmreg.MP + '|' + $ccmreg.SMSClientVersion) } else { Write-Output 'CCMREG=MISSING' }
try {
  $client = Get-CimInstance -Namespace root\CCM -ClassName SMS_Client -ErrorAction Stop
  Write-Output ('ROOTCCM_CLIENT=' + $client.ClientVersion + '|' + $client.SiteCode + '|' + $client.AssignedSiteCode)
} catch { Write-Output ('ROOTCCM_ERR=' + $_.Exception.Message) }
$ls = Get-ChildItem 'C:\Windows\CCM\Logs\*.log' -ErrorAction SilentlyContinue | Select-Object -First 5 -ExpandProperty Name
Write-Output ('CCM_LOGS=' + ($ls -join ','))
Write-Output 'DEEP_CLIENT_DONE'
