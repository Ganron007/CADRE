$ErrorActionPreference = "SilentlyContinue"
$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)
$ns = "root\SMS\site_CAD"

Write-Output "=== AdminService via curl.exe (NTLM) ==="
& curl.exe -k -s --ntlm -u "range\svc_sccm:s3rv1c3_SCCM!" --max-time 20 "https://mbr02.range.local/AdminService/wmi/" 2>&1 | Out-String -Width 250

Write-Output "=== Boot images (media GUIDs) ==="
$bi = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_BootImagePackage -ErrorAction SilentlyContinue
foreach ($b in $bi) {
    Write-Output ("  PKG: {0} | {1} | ImageID={2}" -f $b.PackageID, $b.Name, $b.ImageProperty)
    Write-Output ("    MediaID={0} | SourceSite={1} | Platform={2}" -f $b.MediaID, $b.SourceSite, $b.ImageProperty)
}

Write-Output "=== PXE cert blob (hex) ==="
$pxe = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_PXECertificateInfo -ErrorAction SilentlyContinue
foreach ($p in $pxe) {
    Write-Output ("  PXE: SMSID={0} | Server={1} | Type={2} | Approved={3}" -f ($p.SMSID -join ","), $p.PXEServerName, $p.Type, $p.IsApproved)
    if ($p.Certificate) {
        $certBytes = [byte[]]$p.Certificate
        Write-Output ("  CERT_BYTES={0}" -f $certBytes.Length)
        Write-Output ("  CERT_HEX={0}" -f ([BitConverter]::ToString($certBytes[0..([Math]::Min(31,$certBytes.Length-1))]) -replace '-',''))
    }
}
Write-Output "DONE"
