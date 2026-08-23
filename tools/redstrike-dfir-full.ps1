# CADRE DFIR full graph v9 (90 nodes) — host wrapper (Windows operator).
# Copies the Plan 01 pin + glue to provisioning and runs the phased harness.
# Default: dry-run. Do not pass -Execute until the dry-run prints DFIR_FULL_READY=YES.
# -Execute does NOT reboot VMs or wipe logs. Clean live path: tools/dfir-full-live.ps1
# Never runs the pin on this laptop (win32 default operator is ws01 / local-ws01).
param(
    [switch]$Execute,
    [switch]$SkipSync,
    [string]$Engage = "",
    [string]$Nodes = "",
    [string]$ProvisioningHost = "192.168.77.60",
    [string]$SshKey = "$env:USERPROFILE\.ssh\cadre-provisioning-key",
    [string]$CadreRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$ssh = @("-i", $SshKey, "-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new")
$dest = "vagrant@${ProvisioningHost}"
$stage = Join-Path $env:TEMP "cadre-dfir-full-stage"
New-Item -ItemType Directory -Force -Path $stage | Out-Null

Write-Host "=== redstrike-dfir-full host wrapper $(Get-Date -Format o) ==="
Write-Host "CADRE root: $CadreRoot"
Write-Host "Target: $dest (hybrid orchestrator, 90-node graph v9). Pin is NOT run on this Windows host."

if (-not $SkipSync) {
    $pinTar = Join-Path $stage "redstrike-pin.tgz"
    $linuxTar = Join-Path $stage "linux-auto.tgz"
    $pinRoot = Join-Path $CadreRoot "tools\red-strike"
    $linuxRoot = Join-Path $CadreRoot "attack-matrix\04-automation\linux"

    Write-Host "Packing pin (exclude Windows .venv / pytest cache / .git)..."
    & tar.exe -czf $pinTar `
      --exclude=.venv --exclude=.pytest_cache --exclude=.git --exclude=__pycache__ `
      -C $pinRoot .
    if ($LASTEXITCODE -ne 0) { throw "tar pin failed" }

    Write-Host "Packing 04-automation/linux..."
    & tar.exe -czf $linuxTar -C $linuxRoot .
    if ($LASTEXITCODE -ne 0) { throw "tar linux automation failed" }

    Write-Host "Copy tarballs + glue -> ${dest}:/tmp/"
    scp @ssh `
      $pinTar `
      $linuxTar `
      (Join-Path $CadreRoot "tools\dfir-spine-bootstrap.sh") `
      (Join-Path $CadreRoot "tools\dfir-full-ready-check.py") `
      (Join-Path $CadreRoot "tools\dfir-spine-ready-check.py") `
      (Join-Path $CadreRoot "attack-matrix\04-automation\linux\redstrike-dfir-full.sh") `
      (Join-Path $CadreRoot "attack-matrix\04-automation\linux\redstrike-dfir-spine.sh") `
      (Join-Path $CadreRoot "attack-matrix\Campaign\automation\campaign-graph.yaml") `
      (Join-Path $CadreRoot "attack-matrix\Campaign\automation\lab-profiles.yaml") `
      (Join-Path $CadreRoot "attack-matrix\Campaign\automation\lab-seed-creds.json") `
      (Join-Path $CadreRoot "attack-matrix\Campaign\automation\scope.cadre.example.yaml") `
      "${dest}:/tmp/"
    if ($LASTEXITCODE -ne 0) { throw "scp to provisioning failed" }
}

$remoteFlag = ""
if ($Execute) { $remoteFlag = "--execute" }
$engageExport = ""
if ($Engage) { $engageExport += "REDSTRIKE_ENGAGE='$Engage' " }
if ($Nodes) { $engageExport += "REDSTRIKE_NODES='$Nodes' " }

ssh @ssh $dest "sed -i 's/\r`$//' /tmp/dfir-spine-bootstrap.sh; chmod +x /tmp/dfir-spine-bootstrap.sh; ${engageExport}bash /tmp/dfir-spine-bootstrap.sh $remoteFlag"
if ($LASTEXITCODE -ne 0) {
    throw "remote DFIR full harness failed (exit $LASTEXITCODE). Do not treat execute as ready."
}
Write-Host "Host wrapper finished. Read DFIR_FULL_READY on the remote log under ~/redstrike-runs/."
