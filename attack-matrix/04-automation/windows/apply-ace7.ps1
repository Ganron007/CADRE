$ErrorActionPreference = "Stop"
try {
  Import-Module ActiveDirectory
  Set-Location AD:
  $TargetDN = "CN=chief_command,OU=Command,DC=cadre,DC=local"
  $Principal = "CADRE\hunter_dfir"
  $Rights = [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
  $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
  $ObjectType = [GUID]"00299570-246d-11d0-a768-00aa006e0529"
  $Acl = Get-Acl -Path $TargetDN
  $Identity = New-Object System.Security.Principal.NTAccount($Principal)
  $sid = $Identity.Translate([System.Security.Principal.SecurityIdentifier]).Value
  $exists = $Acl.Access | Where-Object { $_.IdentityReference.Value -eq $sid -and $_.ObjectType -eq $ObjectType }
  if ($exists) { Write-Output "OK: ACE already exists" }
  else {
    $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, $Rights, $AccessControlType, $ObjectType)
    $Acl.AddAccessRule($Rule)
    Set-Acl -Path $TargetDN -AclObject $Acl
    Write-Output "APPLIED"
  }
  # Verify
  $vAcl = Get-Acl -Path $TargetDN
  $v = $vAcl.Access | Where-Object { $_.IdentityReference.Value -eq $sid }
  $v | ForEach-Object { Write-Output "ACE|$($_.ActiveDirectoryRights)|$($_.ObjectType)" }
} catch { Write-Output "FAILED: $_"; exit 1 }
