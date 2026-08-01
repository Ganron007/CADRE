# SCCM mbr02 post-reinstall AdminService verification (part G)
$ErrorActionPreference = 'Continue'

$apps = & "$env:windir\system32\inetsrv\appcmd.exe" list apps 2>$null
Write-Output ("AS_APP_PRESENT=" + ($apps -match 'AdminService'))
Write-Output ("IIS_APPS=" + (($apps | Out-String) -replace "`r`n",' | '))

$pools = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool 2>$null
Write-Output ("AS_POOL_PRESENT=" + ($pools -match 'SMS_AdminService_AppPool'))
Write-Output ("IIS_POOLS=" + (($pools | Out-String) -replace "`r`n",' | '))

Write-Output ("AS_BIN_DIR=" + (Test-Path 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService'))
if (Test-Path 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService') {
    Write-Output ("AS_BIN_FILES=" + ((Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService' -ErrorAction SilentlyContinue | Select-Object -First 10 -ExpandProperty Name) -join ','))
}

try { $as = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_AdminService -ErrorAction Stop); Write-Output ("AS_WMI_CLASS_ROWS=" + $as.Count) } catch { Write-Output ("AS_WMI_CLASS_ERR=" + $_.Exception.Message) }

$id = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Identification' -ErrorAction SilentlyContinue
if ($id) { Write-Output ("SITE_CODE=" + $id.SiteCode); Write-Output ("SITE_NAME=" + $id.SiteName); Write-Output ("SITE_VERSION=" + $id.Version) }

$svcs = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'SMS*' -or $_.DisplayName -like '*SMS*' } | ForEach-Object { $_.Name + ':' + $_.Status }
Write-Output ("SMS_SERVICES=" + ($svcs -join ' | '))

Write-Output "REVIEW_G_DONE"
