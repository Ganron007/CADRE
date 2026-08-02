# Download latest pypykatz.exe (Windows build) via GitHub API
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/SkayTrull/pypykatz/releases/latest' -UseBasicParsing -Headers @{ 'User-Agent' = 'cadre-lab' } -ErrorAction Stop
    Write-Output "TAG $($rel.tag_name)"
    $exeAsset = $rel.assets | Where-Object { $_.name -match 'pypykatz.*\.exe$|\.exe$' } | Select-Object -First 1
    if (-not $exeAsset) { $exeAsset = $rel.assets | Select-Object -First 1 }
    Write-Output "ASSET $($exeAsset.name)"
    Invoke-WebRequest -Uri $exeAsset.browser_download_url -OutFile "$out\pypykatz-new.exe" -UseBasicParsing -ErrorAction Stop
    Write-Output "PYPYKATZ_NEW_SIZE $((Get-Item "$out\pypykatz-new.exe").Length)"
    # version check
    cmd.exe /c "`"$out\pypykatz-new.exe`" --version > `"$out\pypykatz-new-ver.txt`" 2>&1"
    Get-Content "$out\pypykatz-new-ver.txt" -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object { Write-Output "PYKVER|$_" }
} catch { Write-Output "PYPYK_DL_ERR|$($_.Exception.Message)" }
Write-Output 'PYPYKATZ_DL_DONE'
