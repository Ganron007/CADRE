$ErrorActionPreference = 'Continue'
$paths = @(
    'C:\Tools\ADTools',
    "$env:LOCALAPPDATA\Programs",
    "$env:ProgramFiles",
    'C:\Python314',
    'C:\Python313',
    'C:\Python312',
    "$env:APPDATA\Python"
)
$results = @()
foreach ($root in $paths) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'nxc.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'NetExec.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'netexec.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'certipy.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'Rubeus.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'mimikatz.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'impacket*' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'lsassy.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'DonPAPI*' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'bloodyAD*' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'SharpHound.exe' -ErrorAction SilentlyContinue | ForEach-Object { $results += $_.FullName }
}
$results = $results | Sort-Object -Unique
if ($results.Count -eq 0) { Write-Output 'TOOLS_NOT_FOUND' } else { $results | ForEach-Object { Write-Output $_ } }
