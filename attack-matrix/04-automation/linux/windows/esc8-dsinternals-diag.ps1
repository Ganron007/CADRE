# Diagnose why dsinternals import fails despite pip saying it's installed
$ErrorActionPreference = "Continue"
$venv = "C:\Tools\RedStrike\.venv"
$py = "$venv\Scripts\python.exe"

Write-Output "=== sys.path ==="
& $py -c "import sys; [print(p) for p in sys.path]" 2>&1

Write-Output "=== site-packages dsinternals entries ==="
Get-ChildItem "$venv\Lib\site-packages" -Filter "dsinternals*" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "$($_.Name) [$($_.PSIsContainer)]" }

Write-Output "=== attempt direct import ==="
& $py -c "import dsinternals; print('dsinternals_import_OK'); print(dsinternals.__file__)" 2>&1
Write-Output "=== attempt Guid submodule ==="
& $py -c "from dsinternals.system.Guid import Guid; print('Guid_import_OK')" 2>&1

Write-Output "=== dsinternals folder contents (if exists) ==="
if (Test-Path "$venv\Lib\site-packages\dsinternals") {
  Get-ChildItem "$venv\Lib\site-packages\dsinternals" -Recurse -Depth 1 | Select-Object -First 40 | ForEach-Object { Write-Output $_.FullName }
} else { Write-Output "no dsinternals package dir" }

Write-Output "=== DIAG2_DONE ==="
