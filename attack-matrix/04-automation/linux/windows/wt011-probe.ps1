# WT011 — probe impacket smbclient invocation
$ErrorActionPreference = 'Continue'

Write-Output '=== python -m help ==='
python -m impacket.examples.smbclient -h 2>&1 | Select-Object -First 12 | ForEach-Object { Write-Output "MODHELP|$_" }
Write-Output '=== console script help ==='
python 'C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\smbclient.py' -h 2>&1 | Select-Object -First 12 | ForEach-Object { Write-Output "SCRIPTHELP|$_" }
Write-Output 'PROBE_DONE'
