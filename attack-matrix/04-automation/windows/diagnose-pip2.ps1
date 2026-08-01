$ErrorActionPreference = 'Continue'
$python = 'C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\python.exe'
Write-Output '---PIP_CONFIG---'
& $python -m pip config list 2>&1 | ForEach-Object { Write-Output "CONFIG=$_" }
Write-Output '---SIMPLE_INSTALL---'
& $python -m pip install --no-cache-dir requests 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "REQ=$_" }
Write-Output '---NETEXEC_VERBOSE---'
& $python -m pip install --no-cache-dir --verbose NetExec 2>&1 | Select-Object -First 40 | ForEach-Object { Write-Output "VERBOSE=$_" }
Write-Output '---NETEXEC_GIT---'
& $python -m pip install --no-cache-dir git+https://github.com/Pennyw0rth/NetExec.git 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "GIT=$_" }
Write-Output '---DIAG2_END---'
