[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$dir = "C:\Tools\cadre-attack"
if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
$exe = Join-Path $dir "Rubeus.exe"
if (-not (Test-Path -LiteralPath $exe)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe" -OutFile $exe -UseBasicParsing
}
if (Test-Path -LiteralPath $exe) {
    Write-Output "OK:Rubeus"
} else {
    Write-Output "FAIL:Rubeus"
    exit 1
}
