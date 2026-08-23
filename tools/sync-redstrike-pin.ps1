# Adopt standalone RedStrike HEAD into the CADRE Plan 01 pin, then optionally onto provisioning.
# Standalone is the engine SSoT. This pin is the Plan 01 run path.
# CADRE-only overlay (DFIR StepResult timestamps + P-DFIR preflight) is re-applied after the copy.
param(
    [switch]$SkipOverlay,
    [switch]$SkipTests,
    [switch]$PushKali,
    [string]$ProvisioningHost = "192.168.77.60",
    [string]$SshKey = "$env:USERPROFILE\.ssh\cadre-provisioning-key",
    [string]$CadreRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$SisterRoot = (Resolve-Path (Join-Path $CadreRoot "..\RedStrike")).Path
)

$ErrorActionPreference = "Stop"
$pin = Join-Path $CadreRoot "tools\red-strike"
$overlay = Join-Path $PSScriptRoot "red-strike-pin-overlay.patch"

Write-Host "=== sync-redstrike-pin $(Get-Date -Format o) ==="
if (-not (Test-Path (Join-Path $SisterRoot "redstrike\__init__.py"))) {
    throw "standalone RedStrike not found at $SisterRoot"
}
if (-not (Test-Path (Join-Path $pin "redstrike\__init__.py"))) {
    throw "CADRE pin not found at $pin"
}

$sisterHead = (git -C $SisterRoot rev-parse --short HEAD).Trim()
$sisterMsg = (git -C $SisterRoot log -1 --format="%s").Trim()
Write-Host "standalone: $sisterHead $sisterMsg"
Write-Host "pin:        $pin"
Write-Host "overlay:    $overlay"

Write-Host "Copying standalone tracked tree into pin (exclude .git / .venv)..."
$excludeDir = @(
    ".git", ".venv", "venv", "__pycache__", ".pytest_cache", ".ruff_cache",
    "dist", "build", ".agents", ".cursor", ".egg-info"
)
$excludeFile = @(".env", "scope.yaml")
Get-ChildItem -LiteralPath $SisterRoot -Recurse -File -Force | ForEach-Object {
    $rel = $_.FullName.Substring($SisterRoot.TrimEnd("\").Length).TrimStart("\")
    $parts = $rel -split "[\\/]"
    if ($parts | Where-Object { $excludeDir -contains $_ }) { return }
    if ($excludeFile -contains $_.Name) { return }
    $dest = Join-Path $pin $rel
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
}
# Nested-copy leftovers (never ship a second tree inside the pin)
@(
    (Join-Path $pin "tests\tests"),
    (Join-Path $pin "redstrike\redstrike"),
    (Join-Path $pin "docs\docs")
) | ForEach-Object {
    if (Test-Path $_) { Remove-Item $_ -Recurse -Force }
}

if (-not $SkipOverlay) {
    if (-not (Test-Path $overlay)) { throw "missing overlay patch $overlay" }
    Write-Host "Applying CADRE pin overlay..."
    $overlayMarker = Join-Path $pin "PIN-OVERLAY.txt"
    if (Test-Path $overlayMarker) {
        Remove-Item -LiteralPath $overlayMarker -Force
    }
    git -C $pin apply --ignore-whitespace --recount $overlay
    if ($LASTEXITCODE -ne 0) { throw "overlay patch failed" }
}

if (-not $SkipTests) {
    Write-Host "Running pin pytest..."
    $py = Join-Path $pin ".venv\Scripts\python.exe"
    if (-not (Test-Path $py)) { $py = "python" }
    Push-Location $pin
    try {
        & $py -m pytest tests -q --tb=line
        if ($LASTEXITCODE -ne 0) { throw "pin pytest failed" }
    } finally {
        Pop-Location
    }
}

if ($PushKali) {
    $ssh = @("-i", $SshKey, "-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new")
    $dest = "vagrant@${ProvisioningHost}"
    $stage = Join-Path $env:TEMP "cadre-redstrike-pin-sync"
    New-Item -ItemType Directory -Force -Path $stage | Out-Null
    $pinTar = Join-Path $stage "redstrike-pin.tgz"
    Write-Host "Packing pin -> $pinTar"
    & tar.exe -czf $pinTar --exclude=.venv --exclude=.pytest_cache --exclude=.git --exclude=__pycache__ -C $pin .
    if ($LASTEXITCODE -ne 0) { throw "tar pin failed" }
    Write-Host "Copy pin tarball -> ${dest}:/tmp/"
    scp @ssh $pinTar "${dest}:/tmp/redstrike-pin.tgz"
    if ($LASTEXITCODE -ne 0) { throw "scp pin failed" }

    # OpenSSH on Windows wraps a pasted remote command in double quotes, which
    # breaks python print("...") and wrapper quoting. Ship a script instead.
    $remoteSh = Join-Path $stage "redstrike-pin-remote.sh"
    $remoteBody = @'
#!/bin/bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
PIN="$HOME/CADRE/tools/red-strike"
RS="$HOME/RedStrike"
mkdir -p "$PIN"
tar -xzf /tmp/redstrike-pin.tgz -C "$PIN"
if [ ! -x "$PIN/.venv/bin/python" ]; then
  python3 -m venv "$PIN/.venv"
fi
"$PIN/.venv/bin/python" -m pip install -U pip wheel
"$PIN/.venv/bin/python" -m pip install -e "$PIN"
mkdir -p "$RS"
rsync -a --delete --exclude ".venv/" --exclude ".git/" --exclude "__pycache__/" --exclude ".pytest_cache/" --exclude "*.pyc" "$PIN/" "$RS/"
rm -rf "$RS/cadre_strike"
if [ ! -x "$RS/.venv/bin/python" ]; then
  python3 -m venv "$RS/.venv"
fi
"$RS/.venv/bin/python" -m pip install -e "$RS"
python3 - <<'PY'
from pathlib import Path
home = Path.home()
bindir = home / ".local/bin"
bindir.mkdir(parents=True, exist_ok=True)
exe = home / "CADRE/tools/red-strike/.venv/bin"
for name in ("redstrike", "redstrike-campaign", "redstrike-api", "redstrike-mcp"):
    path = bindir / name
    target = exe / name
    path.write_text("#!/bin/bash\nexec \"%s\" \"$@\"\n" % target)
    path.chmod(0o755)
PY
"$PIN/.venv/bin/python" - <<'PY'
import inspect
import redstrike
from redstrike.runtime.orchestrator import StepResult
print("PIN", redstrike.__version__, inspect.getfile(redstrike))
print("STARTED_AT", "started_at" in StepResult.__dataclass_fields__)
PY
"$RS/.venv/bin/python" - <<'PY'
import inspect
import redstrike
print("RS", redstrike.__version__, inspect.getfile(redstrike))
PY
echo "=== wrapper ==="
cat "$HOME/.local/bin/redstrike-campaign"
"$HOME/.local/bin/redstrike-campaign" -h | head -n 8
echo "KALI_PIN_SYNC_OK"
'@
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($remoteSh, ($remoteBody -replace "`r`n", "`n"), $utf8)
    scp @ssh $remoteSh "${dest}:/tmp/redstrike-pin-remote.sh"
    if ($LASTEXITCODE -ne 0) { throw "scp remote script failed" }
    ssh @ssh $dest "bash /tmp/redstrike-pin-remote.sh"
    if ($LASTEXITCODE -ne 0) { throw "remote pin sync failed" }
}

Write-Host "sync-redstrike-pin done (standalone $sisterHead)."
