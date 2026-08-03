#!/usr/bin/env bash
# T109 — ESC16 surface check (DisableExtensionList / SID extension on cadre-CA)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T109 ESC16 surface ==="
ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' '
$ErrorActionPreference="Continue"
$path = "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\cadre-CA\PolicyModules\CertificateAuthority_MicrosoftDefault.Policy"
if (Test-Path $path) {
  $v = (Get-ItemProperty -Path $path -Name DisableExtensionList -ErrorAction SilentlyContinue).DisableExtensionList
  if ($null -eq $v) { Write-Output "ESC16_SID_EXT_ENABLED Default_DisableExtensionList_absent" }
  else { Write-Output ("ESC16_DisableExtensionList=" + ($v -join ",")) }
} else { Write-Output "ESC16_CA_POLICY_PATH_MISSING" }
Write-Output "T109_DONE"
' 'cadre.local'
echo "T109 complete"
