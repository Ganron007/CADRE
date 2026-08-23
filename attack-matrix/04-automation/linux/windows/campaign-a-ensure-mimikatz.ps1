[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$dir = "C:\Tools\cadre-attack"
if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
$exe = Join-Path $dir "mimikatz.exe"
if (-not (Test-Path -LiteralPath $exe)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $zip = Join-Path $dir "mimikatz.zip"
    Invoke-WebRequest -Uri "https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip" -OutFile $zip -UseBasicParsing
    Expand-Archive -Force $zip (Join-Path $dir "mimikatz")
    Copy-Item (Join-Path $dir "mimikatz\x64\mimikatz.exe") $exe
}
if (Test-Path -LiteralPath $exe) {
    Write-Output "OK:mimikatz"
} else {
    Write-Output "FAIL:mimikatz"
    exit 1
}
