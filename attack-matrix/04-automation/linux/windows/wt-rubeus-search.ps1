# Find a usable Rubeus.exe (release URLs + community-compiled mirror)
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$urls = @(
    'https://github.com/GhostPack/Rubeus/releases/download/v2.4.0/Rubeus.exe',
    'https://github.com/GhostPack/Rubeus/releases/download/v2.2.0/Rubeus.exe',
    'https://github.com/GhostPack/Rubeus/releases/download/v1.6.4/Rubeus.exe',
    'https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe'
)
$i = 0
foreach ($u in $urls) {
    $i++
    $dest = "$out\Rubeus-try$i.exe"
    try {
        & curl.exe -L -sS --max-time 60 -o $dest $u 2>&1 | Out-Null
        $sz = (Get-Item $dest -ErrorAction SilentlyContinue).Length
        Write-Output "TRY$i|$sz|$u"
        if ($sz -gt 100000) { Write-Output "CANDIDATE $dest" }
    } catch { Write-Output "TRY$i ERR|$($_.Exception.Message)" }
}
Write-Output 'RUBEUS_SEARCH_DONE'
