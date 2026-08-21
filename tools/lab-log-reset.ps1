# CADRE lab log reset — run from the Windows operator host.
# Copies playbooks to provisioning and executes them (config lane, vagrant).
param(
    [string]$ProvisioningHost = "192.168.77.60",
    [string]$SshKey = "$env:USERPROFILE\.ssh\cadre-provisioning-key",
    [string]$CadreRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$ssh = @("-i", $SshKey, "-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new")
$dest = "vagrant@${ProvisioningHost}"

Write-Host "=== lab-log-reset host wrapper $(Get-Date -Format o) ==="
Write-Host "Copy playbooks -> ${dest}:~/ansible/playbooks/"

scp @ssh `
  (Join-Path $CadreRoot "ansible\playbooks\20-lab-log-reset.yml") `
  (Join-Path $CadreRoot "ansible\playbooks\20-lab-log-reset-verifyOnly.yml") `
  (Join-Path $CadreRoot "tools\lab-log-reset.sh") `
  "${dest}:/tmp/"

ssh @ssh $dest @'
set -euo pipefail
mkdir -p "$HOME/ansible/playbooks"
mv -f /tmp/20-lab-log-reset.yml /tmp/20-lab-log-reset-verifyOnly.yml "$HOME/ansible/playbooks/"
mv -f /tmp/lab-log-reset.sh "$HOME/lab-log-reset.sh"
chmod +x "$HOME/lab-log-reset.sh"
bash "$HOME/lab-log-reset.sh"
'@
