[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
$ok = $false
foreach ($k in @(
    "\\dc01.cadre.local\HKLM\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration",
    "\\192.168.77.10\HKLM\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration"
)) {
    Write-Output ("REG_QUERY=" + $k)
    $q = & reg.exe query $k 2>&1 | Out-String
    Write-Output $q
    if ($q -match "cadre-CA|PolicyModules|DisableExtensionList") { $ok = $true }
}
if ($ok) { Write-Output "T109_OK" } else { Write-Output "T109_FAIL: CA config not readable from ws01"; exit 1 }
