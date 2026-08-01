$ErrorActionPreference = "SilentlyContinue"
$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)
$ns = "root\SMS\site_CAD"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

Write-Output "=== Site Control File: client push search ==="
$scf = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_SiteControlFile -ErrorAction SilentlyContinue
if ($scf) {
    $data = [string]$scf.FileData
    Write-Output "SCF_LEN=$($data.Length)"
    foreach ($kw in @("ClientPush","AutoPush","PushInstallation","Client Push","ClientPushInstallation")) {
        $i = $data.IndexOf($kw)
        if ($i -ge 0) {
            $start = [Math]::Max(0, $i - 120)
            $len = [Math]::Min(400, $data.Length - $start)
            Write-Output "--- match '$kw' at $i ---"
            Write-Output $data.Substring($start, $len)
        } else {
            Write-Output "no match: $kw"
        }
    }
} else {
    Write-Output "SMS_SiteControlFile query failed"
}

Write-Output "=== Script-related classes in provider ==="
$classes = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -List -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "Script" } | Select-Object -ExpandProperty Name
$classes | Out-String -Width 200

Write-Output "=== AdminService retry (TLS12) ==="
try {
    $r = Invoke-RestMethod -Uri "https://mbr02.range.local/AdminService/wmi/" -Credential $cred -Method Get -ErrorAction Stop -TimeoutSec 20
    Write-Output "ADMINSERVICE_OK count=$($r.Count)"
    $r | Select-Object -First 60 | ForEach-Object { Write-Output "  $_" }
} catch {
    Write-Output "ADMINSERVICE_FAIL: $($_.Exception.Message)"
    if ($_.Exception.InnerException) { Write-Output "INNER: $($_.Exception.InnerException.Message)" }
    if ($_.ErrorDetails) { Write-Output "DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE"
