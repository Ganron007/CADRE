$ErrorActionPreference = 'Stop'
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $python) {
    Write-Output PYTHON_MISSING
    exit 1
}

$attempts = @('NetExec', 'netexec')
$installed = $false
foreach ($name in $attempts) {
    Write-Output "INSTALL_TRY=$name"
    try {
        & $python.Source -m pip install $name 2>&1 | Select-Object -Last 10
        $installed = $true
        break
    } catch {
        Write-Output "INSTALL_FAIL=$name"
    }
}

if (-not $installed) {
    Write-Output PIP_INSTALL_FAILED
    exit 1
}

Write-Output INSTALL_DONE
& $python.Source -m pip show NetExec 2>&1 | Select-Object -First 5
