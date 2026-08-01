$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, 'range.local', 'range\svc_naa', 'N@A_s3rv1c3!')
foreach ($cn in @('mbr02','dc03','ws01')) {
    try {
        $pc = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($ctx, $cn)
        if ($pc) {
            Write-Output "=== $cn SPNs ==="
            $pc.ServicePrincipalNames | Out-String -Width 250
        } else {
            Write-Output "=== $cn NOT FOUND ==="
        }
    } catch {
        Write-Output "=== $cn ERR: $($_.Exception.Message) ==="
    }
}
Write-Output "DONE"
