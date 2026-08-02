# Get Rubeus real asset URL via GitHub API + download procdump
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Output '=== RUBEUS RELEASE API ==='
try {
    $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/GhostPack/Rubeus/releases/latest' -UseBasicParsing -Headers @{ 'User-Agent' = 'cadre-lab' } -ErrorAction Stop
    Write-Output "TAG $($rel.tag_name)"
    $rel.assets | ForEach-Object { Write-Output "ASSET|$($_.name)|$($_.browser_download_url)" }
    $exeAsset = $rel.assets | Where-Object { $_.name -match '\.exe$' } | Select-Object -First 1
    if ($exeAsset) {
        Invoke-WebRequest -Uri $exeAsset.browser_download_url -OutFile "$out\Rubeus-official.exe" -UseBasicParsing -ErrorAction Stop
        Write-Output "RUBEUS_DL_SIZE $((Get-Item "$out\Rubeus-official.exe").Length)"
    } else { Write-Output 'NO_EXE_ASSET' }
} catch { Write-Output "API_ERR|$($_.Exception.Message)" }

Write-Output '=== PROCDUMP ==='
try {
    & curl.exe -L -sS -o "$out\procdump64.exe" 'https://live.sysinternals.com/procdump64.exe' 2>&1 | Out-Null
    if (Test-Path "$out\procdump64.exe") { Write-Output "PROCDUMP_SIZE $((Get-Item "$out\procdump64.exe").Length)" } else { Write-Output 'PROCDUMP_MISSING' }
} catch { Write-Output "PROCDUMP_ERR|$($_.Exception.Message)" }

Write-Output 'TOOLS2_DONE'
