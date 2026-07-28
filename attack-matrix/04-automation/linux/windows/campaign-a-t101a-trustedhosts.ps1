[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
try {
    $current = (Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue).Value
    $needed = @("mbr01.child.cadre.local", "192.168.77.22")
    foreach ($n in $needed) {
        if ($current -notlike "*$n*") {
            $value = if ($current) { "$current,$n" } else { $n }
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value $value -Force
            $current = $value
        }
    }
    Write-Output ("TrustedHosts=" + (Get-Item WSMan:\localhost\Client\TrustedHosts).Value)
    Write-Output "TRUSTEDHOSTS_OK"
} catch {
    Write-Output ("TRUSTEDHOSTS_FAIL: " + $_.Exception.Message)
    exit 1
}
