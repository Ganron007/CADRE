$ErrorActionPreference = 'SilentlyContinue'
$python = 'C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\python.exe'
$nxc = Get-Command nxc -ErrorAction SilentlyContinue
$certipy = Get-Command certipy -ErrorAction SilentlyContinue
Write-Output "NXC=$($nxc.Source)"
Write-Output "CERTIPY=$($certipy.Source)"
& $python -m pip show NetExec 2>&1 | ForEach-Object { Write-Output "SHOW=$_" }
