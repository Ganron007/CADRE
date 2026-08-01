$ErrorActionPreference = 'Continue'
$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
Write-Output "--- Rubeus version ---"
cmd /c "`"$rubeus`"" 2>&1 | Select-Object -First 30 | ForEach-Object { Write-Output "V|$_" }
Write-Output "--- Rubeus golden help ---"
cmd /c "`"$rubeus`" golden /help" 2>&1 | Select-Object -First 60 | ForEach-Object { Write-Output "H|$_" }
