# SCCM mbr02 review PART B — IIS apps/pools, AdminService pool identity, win-auth, SMS services
$ErrorActionPreference = 'Continue'

$apps = & "$env:windir\system32\inetsrv\appcmd.exe" list apps 2>$null
Write-Output ("IIS_APPS=" + (($apps | Out-String) -replace "`r`n",' | '))
$pools = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool 2>$null
Write-Output ("IIS_POOLS=" + (($pools | Out-String) -replace "`r`n",' | '))

$poolCfg = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool "SMS_AdminService_AppPool" /config 2>$null
if ($poolCfg) { Write-Output ("AS_POOL_CONFIG=" + (($poolCfg | Out-String) -replace "`r`n",' | ')) } else { Write-Output "AS_POOL=NOT_PRESENT" }

$wa = Get-WindowsFeature Web-Windows-Auth -ErrorAction SilentlyContinue
if ($wa) { Write-Output ("IIS_WIN_AUTH=" + $wa.Installed) } else { Write-Output "IIS_WIN_AUTH=UNKNOWN" }

$svcs = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'SMS*' -or $_.Name -like '*ConfigMgr*' -or $_.DisplayName -like '*SMS*' }
Write-Output ("SMS_SERVICES=" + (($svcs | ForEach-Object { $_.Name + ':' + $_.Status + ':' + $_.StartType }) -join ' | '))
Write-Output "REVIEW_B_DONE"
