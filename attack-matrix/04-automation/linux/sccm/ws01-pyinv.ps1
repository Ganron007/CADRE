# ws01 python/impacket/sql tooling inventory — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
Write-Output '=== python ==='
python --version 2>&1
Write-Output '=== impacket ==='
python -c "import impacket; print('impacket', impacket.__version__)" 2>&1
Write-Output '=== pip ==='
python -m pip --version 2>&1 | Select-Object -First 1
Write-Output '=== mssqlclient.py ==='
python -c "import mssqlclient; print('mssqlclient module ok')" 2>&1
Write-Output '=== pyodbc ==='
python -c "import pyodbc; print('pyodbc', pyodbc.version)" 2>&1
Write-Output '=== sqlcmd ==='
where.exe sqlcmd 2>&1 | Select-Object -First 1
Write-Output '=== curl ==='
where.exe curl.exe 2>&1 | Select-Object -First 1
Write-Output '=== getST.py in impacket examples ==='
python -c "from impacket.examples.getST import getST; print('getST importable')" 2>&1
Write-Output 'INVENTORY_DONE'
