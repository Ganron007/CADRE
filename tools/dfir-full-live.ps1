# CADRE DFIR full graph v9 — clean live prelude (Windows operator).
# Default: graceful reboot of lab VMs, wait healthy, wipe logs. Does NOT attack.
# Pass -Execute only when you want the 90-node run to start immediately after that wipe.
# No VM snapshots.
param(
    [switch]$Execute,
    [switch]$SkipReboot,
    [switch]$SkipWipe,
    [string]$CadreRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

Write-Host "=== dfir-full-live $(Get-Date -Format o) ==="
Write-Host "Execute=$Execute SkipReboot=$SkipReboot SkipWipe=$SkipWipe"
Write-Host "Sequence: reboot (soft) -> wait healthy -> log wipe -> 90-node --execute only if -Execute"
Write-Host "No snapshots. Graph v9 full run (ws01-direct + Kali-only paths + VR hosts in P-DFIR)."

if (-not $SkipReboot) {
    & (Join-Path $CadreRoot "tools\lab-vm-reboot.ps1")
    if ($LASTEXITCODE -ne 0) { throw "lab-vm-reboot failed; not wiping, not executing" }
} else {
    Write-Host "SkipReboot: leaving VMs as-is"
}

if (-not $SkipWipe) {
    & (Join-Path $CadreRoot "tools\lab-log-reset.ps1") -CadreRoot $CadreRoot
    if ($LASTEXITCODE -ne 0) { throw "lab-log-reset failed; not executing" }
} else {
    Write-Host "SkipWipe: not clearing logs"
}

if (-not $Execute) {
    Write-Host "Clean prelude done. Attacks have NOT run."
    Write-Host "When you want the DFIR full live: .\tools\dfir-full-live.ps1 -SkipReboot -SkipWipe -Execute"
    Write-Host "Or reboot+wipe+execute in one shot: .\tools\dfir-full-live.ps1 -Execute"
    exit 0
}

Write-Host "Starting DFIR full-graph --execute (pin on provisioning, not this laptop)."
& (Join-Path $CadreRoot "tools\redstrike-dfir-full.ps1") -Execute -SkipSync
if ($LASTEXITCODE -ne 0) { throw "DFIR full --execute failed" }
