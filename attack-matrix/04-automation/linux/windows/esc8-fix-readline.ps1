# Fix impacket readline on Windows py3.12: install pyreadline3 + pyreadline shim
$ErrorActionPreference = "Continue"
$venv = "C:\Tools\RedStrike\.venv"
$py   = "$venv\Scripts\python.exe"
$pip  = "$venv\Scripts\pip.exe"

Write-Output "=== install pyreadline3 ==="
& $pip install pyreadline3 *> "C:\Tools\cadre-attack\pip-pyreadline3.log"
Write-Output "pip_rc=$LASTEXITCODE"
Get-Content "C:\Tools\cadre-attack\pip-pyreadline3.log" | Select-Object -Last 6

# Verify pyreadline3 imports
& $py -c "import pyreadline3; print('pyreadline3_import=OK')" 2>&1

# Create pyreadline shim (impacket smbclient.py does `import pyreadline as readline`)
$shim = "$venv\Lib\site-packages\pyreadline.py"
if (-not (Test-Path $shim)) {
  @"
# pyreadline shim -> pyreadline3 (Python 3.12 compat)
from pyreadline3 import *  # noqa: F401,F403
"@ | Set-Content -Path $shim -Encoding UTF8
  Write-Output "shim_created=$shim"
} else { Write-Output "shim_exists" }

# Verify `import pyreadline` now resolves
& $py -c "import pyreadline; print('pyreadline_import=OK')" 2>&1
Write-Output "=== FIX_DONE ==="
