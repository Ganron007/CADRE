# Retired 30-node name. Forwards to the 90-node full-graph live prelude.
param(
    [switch]$Execute,
    [switch]$SkipReboot,
    [switch]$SkipWipe,
    [string]$CadreRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)
Write-Host "WARN: dfir-spine-live.ps1 is retired (30-node). Forwarding to dfir-full-live.ps1 (90-node graph v9)."
& (Join-Path $PSScriptRoot "dfir-full-live.ps1") -Execute:$Execute -SkipReboot:$SkipReboot -SkipWipe:$SkipWipe -CadreRoot $CadreRoot
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
