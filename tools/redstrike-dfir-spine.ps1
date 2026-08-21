# Retired 30-node name. Forwards to the 90-node full-graph host wrapper.
param(
    [switch]$Execute,
    [switch]$SkipSync,
    [string]$ProvisioningHost = "192.168.77.60",
    [string]$SshKey = "$env:USERPROFILE\.ssh\cadre-provisioning-key",
    [string]$CadreRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)
Write-Host "WARN: redstrike-dfir-spine.ps1 is retired (30-node). Forwarding to redstrike-dfir-full.ps1."
& (Join-Path $PSScriptRoot "redstrike-dfir-full.ps1") -Execute:$Execute -SkipSync:$SkipSync -ProvisioningHost $ProvisioningHost -SshKey $SshKey -CadreRoot $CadreRoot
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
