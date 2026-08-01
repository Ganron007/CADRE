$ErrorActionPreference = 'Continue'
$py = 'C:\Tools\RedStrike\.venv\Scripts\python.exe'
if (-not (Test-Path $py)) { $py = 'python' }
& $py -c "import impacket; from impacket._version import version; print('IMPACKET', version)" 2>&1
& $py -c "import impacket.examples.secretsdump as s; import inspect; print('HAS_MAIN', 'main' in dir(s))" 2>&1
Write-Output '--- Scripts dir ---'
Get-ChildItem 'C:\Tools\RedStrike\.venv\Scripts' -Filter '*secretsdump*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | ForEach-Object { Write-Output "SCRIPT|$_" }
Get-ChildItem 'C:\Tools\RedStrike\.venv\Scripts' -Filter '*impacket*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | ForEach-Object { Write-Output "SCRIPT|$_" }
