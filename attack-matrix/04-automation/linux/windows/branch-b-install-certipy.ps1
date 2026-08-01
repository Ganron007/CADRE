$ErrorActionPreference = "Stop"
Write-Output "=== installing certipy-ad ==="
python -m pip install --quiet certipy-ad 2>&1 | Select-Object -Last 5
Write-Output "=== verify ==="
python -m certipy 2>&1
python -c "import certipy; print('certipy module OK')" 2>&1
