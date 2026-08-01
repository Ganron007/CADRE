Write-Output "=== pkinittools-src contents ==="
Get-ChildItem C:\Tools\cadre-attack\pkinittools-src -Recurse -Name 2>&1 | Select-Object -First 40
Write-Output "=== t008-getnthash.ps1 content ==="
Get-Content C:\Tools\cadre-attack\t008-getnthash.ps1 2>&1
Write-Output "=== T008-pfx exists? ==="
Get-Item C:\Tools\cadre-attack\T008-dc01.pfx 2>&1 | Select-Object Name, Length
