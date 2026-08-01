# Install dsinternals - capture full output for diagnosis
$ErrorActionPreference = "Continue"
$log = "C:\Tools\cadre-attack\pip-dsinternals.log"
& "C:\Tools\RedStrike\.venv\Scripts\pip.exe" install dsinternals *> $log
Write-Output "pip_rc=$LASTEXITCODE"
Write-Output "=== pip log ==="
Get-Content $log
Write-Output "=== INSTALL_DONE ==="
