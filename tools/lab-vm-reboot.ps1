# CADRE — graceful (soft) reboot of lab VMs from the Windows operator host.
# Uses VMware Tools via `vmrun reset ... soft`. Does not hard-reset unless -Hard.
# Scope: running VMs under %USERPROFILE%\VMs\CADRE plus WS01 (imported).
# Does not touch sister labs (RevEng / Eva7ion / DarkAI) unless their VMX is in those paths.
#
# DFIR live order: reboot (this) → wait healthy → lab-log-reset.ps1 → then spine --execute.
param(
    [switch]$Hard,
    [int]$WaitSeconds = 720,
    [string]$CadreVmDir = (Join-Path $env:USERPROFILE "VMs\CADRE")
)

$ErrorActionPreference = "Stop"

$vmrun = @(
    "${env:ProgramFiles(x86)}\VMware\VMware Workstation\vmrun.exe",
    "${env:ProgramFiles}\VMware\VMware Workstation\vmrun.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $vmrun) { throw "vmrun.exe not found" }

function Get-RunningVmx {
    $lines = & $vmrun -T ws list
    $lines | Where-Object { $_ -like "*.vmx" }
}

function Get-CadreName([string]$vmx) {
    $n = $vmx -replace "\\", "/"
    if ($n -match "/machines/([^/]+)/") { return $Matches[1] }
    if ($n -match "/WS01/") { return "ws01" }
    return (Split-Path $vmx -Leaf)
}

function Test-Tcp([string]$Ip, [int]$Port, [int]$TimeoutMs = 3000) {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $iar = $client.BeginConnect($Ip, $Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
            return $false
        }
        $client.EndConnect($iar)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

$health = [ordered]@{
    dc01         = @{ Ip = "192.168.77.10"; Ports = @(5985) }
    dc02         = @{ Ip = "192.168.77.11"; Ports = @(5985) }
    dc03         = @{ Ip = "192.168.77.12"; Ports = @(5985) }
    mbr01        = @{ Ip = "192.168.77.22"; Ports = @(5985) }
    mbr02        = @{ Ip = "192.168.77.23"; Ports = @(5985) }
    linux01      = @{ Ip = "192.168.77.40"; Ports = @(22) }
    provisioning = @{ Ip = "192.168.77.60"; Ports = @(22) }
    ws01         = @{ Ip = "192.168.77.62"; Ports = @(22, 5985) }
    elk          = @{ Ip = "192.168.77.50"; Ports = @(22, 9200) }
    monitor      = @{ Ip = "192.168.77.55"; Ports = @(22) }
    vr           = @{ Ip = "192.168.77.51"; Ports = @(22) }
}

# Neat order: non-DCs first, child DC, then forest DCs.
$order = @(
    "linux01", "elk", "monitor", "vr", "provisioning",
    "mbr01", "mbr02", "ws01",
    "dc02", "dc03", "dc01"
)

$cadrePrefix = [IO.Path]::GetFullPath($CadreVmDir)
$running = @(Get-RunningVmx | ForEach-Object { $_.Trim() } | Where-Object {
    $full = [IO.Path]::GetFullPath($_)
    $full.StartsWith($cadrePrefix, [StringComparison]::OrdinalIgnoreCase) -or
    ($full -match '(?i)[\\/]WS01[\\/]')
})

if ($running.Count -eq 0) {
    throw "No running CADRE/WS01 VMs. Check vmrun list."
}

$byName = @{}
foreach ($vmx in $running) {
    $byName[(Get-CadreName $vmx)] = $vmx
}

Write-Host "=== lab-vm-reboot $(Get-Date -Format o) mode=$(if ($Hard) {'hard'} else {'soft'}) ==="
Write-Host "vmrun=$vmrun"
foreach ($name in $byName.Keys | Sort-Object) {
    Write-Host ("  running {0,-14} {1}" -f $name, $byName[$name])
}

$mode = if ($Hard) { "hard" } else { "soft" }
$reset = @()
foreach ($name in $order) {
    if ($byName.ContainsKey($name)) { $reset += $name }
}
foreach ($name in ($byName.Keys | Sort-Object)) {
    if ($reset -notcontains $name) { $reset += $name }
}

function Reset-GuestWs01 {
    # Win11 + encrypted vTPM: vmrun reset/stop needs the encryption password.
    Write-Host "reset guest ws01 via SSH (encrypted VMX - not vmrun)"
    $key = Join-Path $env:USERPROFILE ".ssh\cadre-ws01-key"
    $ssh = @(
        "-i", $key,
        "-o", "BatchMode=yes",
        "-o", "StrictHostKeyChecking=accept-new",
        "-o", "ConnectTimeout=10"
    )
    ssh @ssh vagrant@192.168.77.62 "shutdown /r /t 0 /f"
    # ssh often dies when the guest drops; treat that as issued.
    if ($LASTEXITCODE -gt 1) {
        throw "ws01 guest reboot failed (ssh exit $LASTEXITCODE)"
    }
}

foreach ($name in $reset) {
    if ($name -eq "ws01") {
        Reset-GuestWs01
        continue
    }
    $vmx = $byName[$name]
    Write-Host "reset $mode $name"
    & $vmrun -T ws reset $vmx $mode
    if ($LASTEXITCODE -ne 0) {
        throw "vmrun reset failed for $name (exit $LASTEXITCODE)"
    }
}

Write-Host "Waiting up to ${WaitSeconds}s for guest ports..."
$deadline = (Get-Date).AddSeconds($WaitSeconds)
$down = @("not-started")
do {
    $down = @()
    foreach ($name in $reset) {
        if ($health.Keys -notcontains $name) {
            continue
        }
        $spec = $health[$name]
        foreach ($port in $spec.Ports) {
            if (-not (Test-Tcp $spec.Ip $port)) {
                $down += "${name}:$port"
            }
        }
    }
    if ($down.Count -eq 0) {
        Write-Host "All reset VMs healthy."
        break
    }
    Write-Host ("  still down: {0}" -f ($down -join ", "))
    Start-Sleep -Seconds 10
} while ((Get-Date) -lt $deadline)

if ($down.Count -gt 0) {
    throw "Reboot wait timed out. Down: $($down -join ', '). Do not wipe or --execute yet."
}

# Fleet / Sysmon / Zeek need a moment after ports open.
Write-Host "Settle 30s after health..."
Start-Sleep -Seconds 30
Write-Host "lab-vm-reboot OK. Next: lab-log-reset.ps1, then DFIR --execute (operator-gated)."
