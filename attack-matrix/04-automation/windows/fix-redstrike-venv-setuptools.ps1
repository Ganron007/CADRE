$ErrorActionPreference = 'Continue'
$py = 'C:\Tools\RedStrike\.venv\Scripts\python.exe'
if (-not (Test-Path $py)) { $py = 'python' }
Write-Output "--- pip install setuptools<81 (has pkg_resources) ---"
& $py -m pip install "setuptools<81" --force-reinstall 2>&1 | Select-Object -Last 6 | ForEach-Object { Write-Output "PIP|$_" }
Write-Output "--- verify pkg_resources ---"
& $py -c "import pkg_resources; print('PKG_RESOURCES_OK')" 2>&1
