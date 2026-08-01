# Check whether the ConfigMgr client is installed + online on mbr02
$ErrorActionPreference = 'Continue'
$svc = Get-Service -Name CcmExec -ErrorAction SilentlyContinue
if ($svc) { Write-Output ("CCMEXEC=" + $svc.Status) } else { Write-Output 'CCMEXEC=MISSING' }
Write-Output ("CCMDIR=" + (Test-Path 'C:\Windows\CCM'))
$ccmclient = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($ccmclient) { Write-Output ("CCMKEY=" + $ccmclient.SiteCode + ' ' + $ccmclient.MP) } else { Write-Output 'CCMKEY=MISSING' }
Write-Output ('CCM_CLIENT_VERSION=' + (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM\Version' -Name 'CCMVersion' -ErrorAction SilentlyContinue).CCMVersion)
Write-Output 'CLIENT_CHECK_DONE'
