# SCCM mbr02 review PART C — exact site version, provider registry values, roles list
$ErrorActionPreference = 'Continue'
$id = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Identification' -ErrorAction SilentlyContinue
if ($id) { Write-Output ("ID_ALL=" + (($id.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object { $_.Name + '=' + $_.Value }) -join '|')) } else { Write-Output "ID_KEY=NONE" }
$prov = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Providers' -ErrorAction SilentlyContinue
if ($prov) { Write-Output ("PROV_ALL=" + (($prov.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object { $_.Name + '=' + $_.Value }) -join '|')) } else { Write-Output "PROV_KEY=NONE" }
try { $site = Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_Site -ErrorAction Stop; Write-Output ("SITE_ALL=" + (($site.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object { $_.Name + '=' + $_.Value }) -join '|')) } catch { Write-Output ("SITE_ERR=" + $_.Exception.Message) }
try { $roles = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_SCI_SysResUse -ErrorAction Stop | Select-Object -ExpandProperty RoleName -Unique); Write-Output ("ROLES=" + ($roles -join '|')) } catch { Write-Output ("ROLES_ERR=" + $_.Exception.Message) }
Write-Output "REVIEW_C_DONE"
