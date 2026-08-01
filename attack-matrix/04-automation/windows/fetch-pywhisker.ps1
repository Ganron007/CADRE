# Fetch pywhisker.py from ShutdownRepo/pywhisker
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$outDir = 'C:\Tools\cadre-attack'

$urls = @(
  'https://raw.githubusercontent.com/ShutdownRepo/pywhisker/main/pywhisker.py',
  'https://raw.githubusercontent.com/ShutdownRepo/pywhisker/master/pywhisker.py',
  'https://raw.githubusercontent.com/ShutdownRepo/pywhisker/main/pyWhisker.py'
)

foreach ($u in $urls) {
  try {
    $r = Invoke-WebRequest -Uri $u -UseBasicParsing -ErrorAction Stop
    [System.IO.File]::WriteAllText("$outDir\pywhisker.py", $r.Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Output "OK|$u|$($r.Content.Length)"
    break
  } catch {
    Write-Output "FAIL|$u|$($_.Exception.Message)"
  }
}
if (Test-Path "$outDir\pywhisker.py") {
  Write-Output "SAVED|$((Get-Item "$outDir\pywhisker.py").Length)"
} else {
  # Fallback: download repo tarball via codeload and extract
  Write-Output 'TRY_TARBALL'
  try {
    Invoke-WebRequest -Uri 'https://codeload.github.com/ShutdownRepo/pywhisker/zip/refs/heads/main' -OutFile "$outDir\pywhisker.zip" -UseBasicParsing
    Expand-Archive "$outDir\pywhisker.zip" -DestinationPath "$outDir\pywhisker-src" -Force
    Get-ChildItem "$outDir\pywhisker-src" -Recurse -Filter *.py | ForEach-Object { Write-Output "PYFILE|$($_.FullName)" }
  } catch {
    Write-Output "TARBALL_FAIL|$($_.Exception.Message)"
  }
}
Write-Output 'FETCH_DONE'
