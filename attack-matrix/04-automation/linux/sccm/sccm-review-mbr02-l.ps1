# SCCM mbr02 part L — minimal: SMS Admins membership + AdminService state
net localgroup "SMS Admins"

$apps = & "$env:windir\system32\inetsrv\appcmd.exe" list apps 2>$null
Write-Output ("AS_APP_PRESENT=" + ($apps -match 'AdminService'))
$pools = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool 2>$null
Write-Output ("AS_POOL_PRESENT=" + ($pools -match 'SMS_AdminService_AppPool'))
Write-Output ("AS_BIN_DIR=" + (Test-Path 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService'))
Write-Output "REVIEW_L_DONE"
