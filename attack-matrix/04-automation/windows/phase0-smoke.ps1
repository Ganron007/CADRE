$ErrorActionPreference = 'Stop'
$result = @{}

try {
    $result.host = [System.Net.Dns]::GetHostName()
} catch {
    $result.host = 'HOST_FAIL'
}

try {
    $result.user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
} catch {
    $result.user = 'USER_FAIL'
}

$checkPaths = @(
    "$env:LOCALAPPDATA\Programs\nxc\nxc.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python313\Scripts\nxc.exe",
    "C:\Python313\Scripts\nxc.exe",
    "$env:ProgramFiles\nxc\nxc.exe",
    "$env:APPDATA\Python\Python313\Scripts\nxc.exe"
)

$result.nxc = 'NXC_MISSING'
foreach ($path in $checkPaths) {
    if (Test-Path -LiteralPath $path -ErrorAction SilentlyContinue) {
        $result.nxc = $path
        break
    }
}

$certipyPaths = @(
    "$env:LOCALAPPDATA\Programs\Python\Python313\Scripts\certipy.exe",
    "$env:ProgramFiles\certipy\certipy.exe",
    "$env:APPDATA\Python\Python313\Scripts\certipy.exe",
    "C:\Python313\Scripts\certipy.exe"
)

$result.certipy = 'CERTIPY_MISSING'
foreach ($path in $certipyPaths) {
    if (Test-Path -LiteralPath $path -ErrorAction SilentlyContinue) {
        $result.certipy = $path
        break
    }
}

$result | ConvertTo-Json -Compress
