# SCCM mbr02 review PART F — site role/component inventory AS svc_sccm (SCCM admin, RBAC-visible)
# Runs as svc_naa (local admin) but queries the SMS provider with EXPLICIT svc_sccm creds (DCOM/PacketPrivacy).
$ErrorActionPreference = 'Continue'

$sec = New-Object System.Management.ConnectionOptions
$sec.Username = 'RANGE\svc_sccm'
$sec.Password = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$sec.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
# NOTE: must connect by FQDN, not localhost — DCOM rejects alternate creds for local connections.
$scope = New-Object System.Management.ManagementScope('\\mbr02.range.local\root\SMS\site_CAD', $sec)
try { $scope.Connect(); Write-Output "SCOPE_CONNECT=OK" } catch { Write-Output ("SCOPE_CONNECT_ERR=" + $_.Exception.Message); exit 1 }

function Q([string]$wql) {
    try {
        $searcher = New-Object System.Management.ManagementObjectSearcher($scope, (New-Object System.Management.ObjectQuery($wql)))
        return @($searcher.Get())
    } catch { Write-Output ("Q_ERR[" + $wql + "]=" + $_.Exception.Message); return @() }
}

# 1) All site system roles on mbr02
$roles = Q "SELECT RoleName, SiteSystem FROM SMS_SCI_SysResUse"
Write-Output ("SYSRES_COUNT=" + $roles.Count)
foreach ($o in $roles) { Write-Output ("ROLE=" + $o['RoleName'] + '|' + $o['SiteSystem']) }

# 2) Components (any AdminService / Provider related)
$comps = Q "SELECT ComponentName, MachineName FROM SMS_SCI_Component"
Write-Output ("COMP_COUNT=" + $comps.Count)
$as = @($comps | Where-Object { $_['ComponentName'] -match 'Admin|Provider|Service' })
Write-Output ("ADMINSVC_RELATED=" + (($as | ForEach-Object { $_['ComponentName'] + ':' + $_['MachineName'] }) -join '|'))
$allnames = @($comps | ForEach-Object { $_['ComponentName'] } | Sort-Object -Unique)
Write-Output ("ALL_COMPONENTS=" + ($allnames -join '|'))

# 3) SMS Provider role props (look for an AdminService enable flag in Props)
$pr = Q "SELECT RoleName, SiteSystem, Props FROM SMS_SCI_SysResUse WHERE RoleName LIKE '%Provider%'"
Write-Output ("PROV_ROLE_COUNT=" + $pr.Count)
foreach ($o in $pr) {
    $props = $o['Props']
    Write-Output ("PROV_ROLE=" + $o['RoleName'] + '|' + $o['SiteSystem'])
    if ($props) { Write-Output ("PROV_PROPS=" + (($props | ForEach-Object { $_.PropertyName + '=' + $_.Value1 }) -join '|')) }
}

# 4) AdminService-related class + component config flag
$flag = Q "SELECT * FROM SMS_SCI_Component WHERE ComponentName = 'SMS_ADMIN_SERVICE'"
Write-Output ("ADMINSVC_COMP_COUNT=" + $flag.Count)

Write-Output "REVIEW_F_DONE"
