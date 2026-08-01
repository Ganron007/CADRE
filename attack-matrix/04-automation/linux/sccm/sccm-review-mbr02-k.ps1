# SCCM mbr02 part K — SMS Admins membership (svc_sccm), AdminService re-check, IIS features, Defender
$ErrorActionPreference = 'Continue'

$g = @(Get-LocalGroupMember -Group 'SMS Admins' -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
Write-Output ("SMS_ADMINS=" + ($g -join ','))

$apps = & "$env:windir\system32\inetsrv\appcmd.exe" list apps 2>$null
Write-Output ("AS_APP_PRESENT=" + ($apps -match 'AdminService'))
$pools = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool 2>$null
Write-Output ("AS_POOL_PRESENT=" + ($pools -match 'SMS_AdminService_AppPool'))
Write-Output ("AS_BIN_DIR=" + (Test-Path 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService'))

$feat = @(Get-WindowsOptionalFeature -Online -FeatureName IIS-* -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Enabled' } | Select-Object -ExpandProperty FeatureName)
Write-Output ("IIS_FEATURES=" + ($feat -join ','))

$wd = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
if ($wd) { Write-Output ("DEFENDER=" + $wd.Status) } else { Write-Output "DEFENDER=NONE" }

Write-Output "REVIEW_K_DONE"
