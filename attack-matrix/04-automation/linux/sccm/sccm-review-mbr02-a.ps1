# SCCM mbr02 review PART A — site identity, providers, WMI provider, AdminService role/class/DLL
$ErrorActionPreference = 'Continue'
Write-Output ("HOST=" + $env:COMPUTERNAME)

$id = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Identification' -ErrorAction SilentlyContinue
if ($id) { Write-Output ("SITE_CODE=" + $id.SiteCode); Write-Output ("SITE_NAME=" + $id.SiteName); Write-Output ("SITE_VERSION=" + $id.Version) } else { Write-Output "SITE_ID_REG=NONE" }

$prov = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Providers' -ErrorAction SilentlyContinue
if ($prov) { Write-Output ("PROVIDERS=" + ($prov.Providers -join ',')) } else { Write-Output "PROVIDERS=NONE" }

try { $site = Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_Site -ErrorAction Stop; Write-Output ("WMI_SITE=" + $site.SiteCode + '|' + $site.Version + '|' + $site.ServerName) } catch { Write-Output ("WMI_SITE_ERR=" + $_.Exception.Message) }

try { $p = Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName __Win32Provider -Filter "Name='SMSProv'" -ErrorAction Stop; Write-Output ("SMS_PROVIDER_REG=" + $p.Clsid) } catch { Write-Output ("SMS_PROVIDER_REG_ERR=" + $_.Exception.Message) }

try { $role = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_SCI_SysResUse -Filter "RoleName='SMS_ADMIN_SERVICE'" -ErrorAction Stop); Write-Output ("ADMINSVC_ROLE_COUNT=" + $role.Count); foreach ($r in $role) { Write-Output ("ADMINSVC_ROLE=" + $r.RoleName + '|' + $r.NALPath) } } catch { Write-Output ("ADMINSVC_ROLE_ERR=" + $_.Exception.Message) }

try { $as = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_AdminService -ErrorAction Stop); Write-Output ("SMS_ADMINSVC_CLASS_COUNT=" + $as.Count) } catch { Write-Output ("SMS_ADMINSVC_CLASS_ERR=" + $_.Exception.Message) }

$dll = 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService\Microsoft.ConfigurationManagement.AdminService.dll'
if (Test-Path $dll) { Write-Output ("AS_DLL_VERSION=" + (Get-Item $dll).VersionInfo.FileVersion) } else { Write-Output "AS_DLL=MISSING" }
Write-Output ("AS_BIN_DIR=" + (Test-Path 'C:\Program Files\Microsoft Configuration Manager\bin\AdminService'))
Write-Output "REVIEW_A_DONE"
