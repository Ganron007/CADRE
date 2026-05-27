# CADRE common functions — dot-sourced by all attack scripts
# Usage: . .\lib\common.ps1

$Script:RED = "Red"
$Script:GREEN = "Green"
$Script:YELLOW = "Yellow"
$Script:CYAN = "Cyan"

function log   { Write-Host "[*] $($args[0])" -ForegroundColor $Script:CYAN }
function step  { Write-Host "`n[>] $($args[0])" -ForegroundColor $Script:YELLOW }
function ok    { Write-Host "  [+] $($args[0])" -ForegroundColor $Script:GREEN }
function fail  { Write-Host "  [-] $($args[0])" -ForegroundColor $Script:RED }

function run_cmd {
    Write-Host "  `$ $($args[0])" -ForegroundColor $Script:YELLOW
    Invoke-Expression $args[0]
    return $LASTEXITCODE
}

function result {
    # result <exitcode> <message> — honest pass/fail, mirrors linux/lib/common.sh
    if ($args[0] -eq 0 -or $null -eq $args[0]) { ok $args[1] }
    else { fail "$($args[1]) (exit $($args[0]))" }
}

function require_tool {
    if (-not (Get-Command $args[0] -ErrorAction SilentlyContinue)) {
        fail "Required tool not found: $($args[0])"
        exit 1
    }
}

function start_attack {
    Write-Host "`n  ========== WT#$($args[0]) - $($args[1]) ==========" -ForegroundColor $Script:CYAN
    log "Starting at $(Get-Date -Format 'HH:mm:ss')"
}

function print_banner {
    Write-Host "`n  CADRE Attack Automation - $($args[0])" -ForegroundColor $Script:CYAN
    Write-Host "  $(Get-Date)"
    Write-Host "================================================"
}
