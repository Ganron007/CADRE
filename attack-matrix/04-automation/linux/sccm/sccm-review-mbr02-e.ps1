# SCCM mbr02 review PART E — how the SMS Provider + AdminService are actually registered (site config)
$ErrorActionPreference = 'Continue'

# 1) All site system roles on mbr02 (how the provider is stored)
try {
    $roles = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_SCI_SysResUse -ErrorAction Stop)
    Write-Output ("SYSRES_COUNT=" + $roles.Count)
    foreach ($r in $roles) { Write-Output ("ROLE=" + $r.RoleName + '|' + $r.SiteSystem) }
} catch { Write-Output ("SYSRES_ERR=" + $_.Exception.Message) }

# 2) SMS Provider locations (root\SMS system class — how clients locate the provider)
try {
    $pl = @(Get-CimInstance -Namespace 'root\SMS' -ClassName SMS_ProviderLocation -ErrorAction Stop)
    foreach ($p in $pl) { Write-Output ("PROV_LOC=" + $p.Machine + '|' + $p.ProviderForSite + '|' + $p.SiteCode + '|' + $p.Locality) }
} catch { Write-Output ("PROV_LOC_ERR=" + $_.Exception.Message) }

# 3) Site components — is there any AdminService component registered?
try {
    $comps = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_SCI_Component -ErrorAction Stop | Select-Object -ExpandProperty ComponentName -Unique)
    Write-Output ("COMPONENTS=" + ($comps -join '|'))
    $as = $comps | Where-Object { $_ -match 'Admin|Service' }
    Write-Output ("ADMINSVC_COMPONENT=" + (($as -join '|') ))
} catch { Write-Output ("COMP_ERR=" + $_.Exception.Message) }

# 4) SMS Provider role properties (SMS_SCI_SysResUse for the provider — look for an AdminService flag)
try {
    $pr = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_SCI_SysResUse -Filter "RoleName LIKE '%Provider%'" -ErrorAction Stop)
    Write-Output ("PROV_ROLE_LIKE_COUNT=" + $pr.Count)
    foreach ($p in $pr) { Write-Output ("PROV_ROLE_LIKE=" + $p.RoleName + '|' + $p.SiteSystem) }
} catch { Write-Output ("PROV_ROLE_LIKE_ERR=" + $_.Exception.Message) }

# 5) Tail of the site-side AdminService/provider deployment log
foreach ($log in @('C:\Program Files\Microsoft Configuration Manager\Logs\smsadminui.log','C:\Program Files\Microsoft Configuration Manager\Logs\SMSAdminUI.log','C:\Program Files\Microsoft Configuration Manager\Logs\smsprov.log')) {
    if (Test-Path $log) { Write-Output ("LOG_TAIL_" + (Split-Path $log -Leaf) + "=" + ((Get-Content $log -Tail 8 -ErrorAction SilentlyContinue) -join ' | ')) } else { Write-Output ("LOG_" + (Split-Path $log -Leaf) + "=MISSING") }
}

Write-Output "REVIEW_E_DONE"
