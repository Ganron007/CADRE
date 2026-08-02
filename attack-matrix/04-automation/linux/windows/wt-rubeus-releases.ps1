# Check for newer Rubeus release assets
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    $rels = Invoke-RestMethod -Uri 'https://api.github.com/repos/GhostPack/Rubeus/releases?per_page=10' -UseBasicParsing -Headers @{ 'User-Agent' = 'cadre-lab' } -ErrorAction Stop
    foreach ($r in $rels) {
        Write-Output "REL|$($r.tag_name)|$($r.prerelease)|$($r.assets.Count) assets"
        $r.assets | ForEach-Object { Write-Output "  ASSET|$($_.name)|$($_.size)" }
    }
} catch { Write-Output "API_ERR|$($_.Exception.Message)" }
Write-Output 'RUBEUS_RELS_DONE'
