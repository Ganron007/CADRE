[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
try {
    $s = Get-Service -Name CcmExec -ErrorAction SilentlyContinue
    if ($s) { Write-Output ("T036_OK: CcmExec service status: " + $s.Status) } else { Write-Output "T036_INFO: CcmExec service not found" }
} catch { Write-Output ("T036_INFO: " + $_) }
Write-Output "T036_OK: client push relay check complete"
