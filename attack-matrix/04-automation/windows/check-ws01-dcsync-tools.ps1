$ErrorActionPreference = 'Continue'
Write-Output '--- ADTools ---'
Get-ChildItem 'C:\Tools\ADTools' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | ForEach-Object { Write-Output $_ }
Write-Output '--- mimikatz search ---'
Get-ChildItem 'C:\Tools' -Recurse -Filter 'mimikatz*' -ErrorAction SilentlyContinue | Select-Object -First 10 -ExpandProperty FullName | ForEach-Object { Write-Output $_ }
Write-Output '--- python impacket ---'
python -c "import impacket; print('impacket OK')" 2>&1
Write-Output '--- secretsdump ---'
Get-Command secretsdump.py -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
python -m impacket.secretsdump --help 2>&1 | Select-Object -First 3
Write-Output '--- Rubeus ---'
Get-ChildItem 'C:\Tools' -Recurse -Filter 'Rubeus.exe' -ErrorAction SilentlyContinue | Select-Object -First 5 -ExpandProperty FullName | ForEach-Object { Write-Output $_ }
