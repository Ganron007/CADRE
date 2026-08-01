$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, 'range.local', 'range\svc_naa', 'N@A_s3rv1c3!')
$pc = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($ctx, 'mbr02')
if (-not $pc) { Write-Output "MBR02 NOT FOUND"; exit 1 }
Write-Output "=== SPNs before ==="
$pc.ServicePrincipalNames | Out-String -Width 250

$spns = $pc.ServicePrincipalNames
$added = @()
if (-not $spns.Contains('cifs/mbr02.range.local')) { $spns.Add('cifs/mbr02.range.local') | Out-Null; $added += 'cifs/mbr02.range.local' }
if (-not $spns.Contains('HTTP/mbr02.range.local')) { $spns.Add('HTTP/mbr02.range.local') | Out-Null; $added += 'HTTP/mbr02.range.local' }
Write-Output "ADDING: $($added -join ', ')"
$pc.Save()
Write-Output "SAVE_OK"

# re-read
$pc2 = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($ctx, 'mbr02')
Write-Output "=== SPNs after ==="
$pc2.ServicePrincipalNames | Out-String -Width 250
Write-Output "DONE"
