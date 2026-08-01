# SCCM mbr02 configuration review (run via nxc smb -X from provisioning)
# Gathers: site identity, SMS Provider, AdminService (IIS/files/role), site services.
$ErrorActionPreference = 'Continue'

Write-Output ("HOST=" + $env:COMPUTERNAME)

# 1) Site identity (registry)
$id = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Identification' -ErrorAction SilentlyContinue
if ($id) {
    Write-Output ("SITE_CODE=" + $id.SiteCode)
    Write-Output ("SITE_NAME=" + $id.SiteName)
    Write-Output ("SITE_VERSION=" + $id.Version)
} else { Write-Output "SITE_ID_REG=NONE" }

# 2) SMS Providers registered
$prov = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Providers' -ErrorAction SilentlyContinue
if ($prov) { Write-Output ("PROVIDERS=" + ($prov.Providers -join ',')) } else { Write-Output "PROVIDERS=NONE" }

# 3) SMS Provider WMI namespace reachable + site object
try {
    $site = Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_Site -ErrorAction Stop
    Write-Output ("WMI_SITE=" + $site.SiteCode + '|' + $site.Version + '|' + $site.ServerName)
} catch { Write-Output ("WMI_SITE_ERR=" + $_.Exception.Message) }

# 4) AdminService role registered in the provider (SMS_ADMIN_SERVICE / SMS Admin Service)
try {
    $role = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_SCI_SysResUse -Filter "RoleName='SMS_ADMIN_SERVICE'" -ErrorAction Stop)
    Write-Output ("ADMINSVC_ROLE_COUNT=" + $role.Count)
    foreach ($r in $role) { Write-Output ("ADMINSVC_ROLE=" + $r.RoleName + '|' + $r.NALPath) }
} catch { Write-Output ("ADMINSVC_ROLE_ERR=" + $_.Exception.Message) }

# 4b) SMS_AdminService WMI class (registered by the AdminService installer)
try {
    $as = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_AdminService -ErrorAction Stop)
    Write-Output ("SMS_ADMINSVC_CLASS_COUNT=" + $as.Count)
    foreach ($a in $as) { Write-Output ("SMS_ADMINSVC_CLASS=" + ($a.PSObject.Properties | ForEach-Object { $_.Name + '=' + $_.Value }) -join '|') }
} catch { Write-Output ("SMS_ADMINSVC_CLASS_ERR=" + $_.Exception.Message) }

# 4c) AdminService DLL version (build tells the CB version)
$dll = 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService\Microsoft.ConfigurationManagement.AdminService.dll'
if (Test-Path $dll) {
    Write-Output ("AS_DLL_VERSION=" + (Get-Item $dll).VersionInfo.FileVersion)
} else { Write-Output "AS_DLL=MISSING" }

# 5) AdminService physical files
Write-Output ("AS_BIN_DIR=" + (Test-Path 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService'))
Write-Output ("AS_ROOT_DIR=" + (Test-Path 'C:\Program Files\Microsoft Configuration Manager\AdminService'))
if (Test-Path 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService') {
    Write-Output ("AS_BIN_FILES=" + ((Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService' -ErrorAction SilentlyContinue | Select-Object -First 15 -ExpandProperty Name) -join ','))
}

# 6) IIS applications + app pools (AdminService web app?)
$apps = & "$env:windir\system32\inetsrv\appcmd.exe" list apps 2>$null
Write-Output ("IIS_APPS=" + (($apps | Out-String) -replace "`r`n",' | '))
$pools = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool 2>$null
Write-Output ("IIS_POOLS=" + (($pools | Out-String) -replace "`r`n",' | '))
# App pool identity for the AdminService pool (CD-attack requirement)
$asPool = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool "SMS_AdminService_AppPool" /text:* 2>$null
if ($LASTEXITCODE -eq 0 -and $asPool) {
    $identity = & "$env:windir\system32\inetsrv\appcmd.exe" list apppool "SMS_AdminService_AppPool" /config 2>$null
    Write-Output ("AS_POOL_CONFIG=" + (($identity | Out-String) -replace "`r`n",' | '))
} else {
    Write-Output "AS_POOL=NOT_PRESENT"
}
# Windows Authentication IIS feature (AdminService requires it)
$wa = Get-WindowsFeature Web-Windows-Auth -ErrorAction SilentlyContinue
if ($wa) { Write-Output ("IIS_WIN_AUTH=" + $wa.Installed) } else { Write-Output "IIS_WIN_AUTH=UNKNOWN" }

# 7) SMS services
$svcs = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'SMS*' -or $_.Name -like '*ConfigMgr*' -or $_.DisplayName -like '*SMS*' }
Write-Output ("SMS_SERVICES=" + (($svcs | ForEach-Object { $_.Name + ':' + $_.Status + ':' + $_.StartType }) -join ' | '))

# 8) WMI provider registration for the site namespace
try {
    $p = Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName __Win32Provider -Filter "Name='SMSProv'" -ErrorAction Stop
    Write-Output ("SMS_PROVIDER_REG=" + $p.Clsid)
} catch { Write-Output ("SMS_PROVIDER_REG_ERR=" + $_.Exception.Message) }

Write-Output "REVIEW_DONE"
