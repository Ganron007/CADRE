#Requires -Version 5.1
<#
.SYNOPSIS
  RedStrike Campaign v3 — native ws01 operator mode (Rule 1 strict).

.DESCRIPTION
  Runs CampaignOrchestrator ON domain-joined ws01 (no provisioning SSH wrap).
  Pair with the hybrid harness on .60:
    attack-matrix/04-automation/linux/redstrike-campaign-v3-full-run.sh
    (--operator provisioning)

  Native mode prefers typed intents (local tools on PATH). Bash harness scripts
  under 04-automation/linux still need Git Bash if you pass -PreferScript.

.EXAMPLE
  .\redstrike-campaign-v3-ws01-native.ps1 -DryRun
  .\redstrike-campaign-v3-ws01-native.ps1 -Execute
#>
[CmdletBinding()]
param(
  [string]$Engage = ("camp-v3-ws01-" + (Get-Date -Format "yyyyMMdd")),
  [string]$Beachhead = "windows",
  [string]$CadreRoot = $env:CADRE_ROOT,
  [switch]$Execute,
  [switch]$PreferScript,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not $CadreRoot) {
  $candidates = @(
    "C:\CADRE",
    "C:\STUDY\Github\CADRE-Platform\CADRE",
    (Join-Path $PSScriptRoot "..\..\..\..")
  )
  foreach ($c in $candidates) {
    if (Test-Path (Join-Path $c "attack-matrix\Campaign\automation\campaign-graph.yaml")) {
      $CadreRoot = (Resolve-Path $c).Path
      break
    }
  }
}
if (-not $CadreRoot) { throw "Set CADRE_ROOT to the CADRE repo root" }

$env:CADRE_ROOT = $CadreRoot
$env:CADRE_AUTOMATION_ROOT = Join-Path $CadreRoot "attack-matrix\04-automation\linux"
$env:REDSTRIKE_SEED = Join-Path $CadreRoot "attack-matrix\Campaign\automation\lab-seed-creds.json"
$env:REDSTRIKE_OPERATOR = "ws01"

$LogDir = Join-Path $env:USERPROFILE "redstrike-runs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$stamp = Get-Date -Format "yyyyMMddTHHmmssZ"
$Log = Join-Path $LogDir "$Engage-$stamp.log"

function Invoke-Logged {
  param([scriptblock]$Block)
  & $Block *>&1 | Tee-Object -FilePath $Log -Append
}

if (-not (Get-Command redstrike-campaign -ErrorAction SilentlyContinue)) {
  throw "redstrike-campaign not on PATH — activate RedStrike venv / pip install -e ."
}

$doExecute = $Execute -and -not $DryRun
$modeLabel = if ($doExecute) { "EXECUTE" } else { "DRY-RUN" }

Invoke-Logged {
  Write-Host "=== RedStrike NATIVE ws01 run | engage=$Engage | $modeLabel | $(Get-Date -Format o) ==="
  Write-Host "operator=ws01 beachhead=$Beachhead"
  Write-Host "CADRE_ROOT=$env:CADRE_ROOT"
  whoami
  hostname
}

redstrike-campaign start --beachhead $Beachhead --operator ws01 --engage $Engage | Tee-Object -FilePath $Log -Append

foreach ($gate in @("dcsync","ticket","forest","persistence","acl_write","site_takeover")) {
  redstrike-campaign approve --gate $gate --engage $Engage --operator ws01 --note "operator-approved native ws01 harness" |
    Tee-Object -FilePath $Log -Append
}

function Invoke-RsPhase {
  param([string]$Phase, [string]$Branch = "spine", [string]$Beach = $Beachhead)
  Write-Host "--- run phase=$Phase branch=$Branch beachhead=$Beach operator=ws01 ---"
  $args = @(
    "run", "--phase", $Phase, "--beachhead", $Beach, "--operator", "ws01",
    "--engage", $Engage, "--branch", $Branch, "--no-stop-on-hitl"
  )
  if ($doExecute) { $args += "--execute" }
  if ($PreferScript) { $args += "--prefer-script" }
  & redstrike-campaign @args
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "phase $Phase branch $Branch returned $LASTEXITCODE"
  }
}

# Spine (windows beachhead = attack identity on this host)
Invoke-RsPhase "0.5-3" "spine" "windows"
Invoke-RsPhase "3.5-4" "spine" "windows"
Invoke-RsPhase "5-8" "spine" "windows"

# Branches that belong on ws01
Invoke-RsPhase "4-5" "A" "windows"
Invoke-RsPhase "5" "B" "windows"
Invoke-RsPhase "8" "C" "windows"
Invoke-RsPhase "5" "G" "windows"

# H / E / F / Branch D linux01 / T031 spray originate off-ws01 — use provisioning harness
Write-Host "NOTE: Branch H, E, F, D(linux01), T031 → run via provisioning harness (--operator provisioning)"

redstrike-campaign status --engage $Engage --operator ws01 --json |
  Tee-Object -FilePath (Join-Path $LogDir "$Engage-final-status.json")

Write-Host "=== NATIVE ws01 run complete — log=$Log ==="
