$ErrorActionPreference = "SilentlyContinue"
if (Test-Path C:\Tools\cadre-attack\rubeus-src) { Remove-Item C:\Tools\cadre-attack\rubeus-src -Recurse -Force }
Expand-Archive -Path C:\Tools\ADTools\Rubeus-master.zip -DestinationPath C:\Tools\cadre-attack\rubeus-src -Force
Write-Output "=== Files ==="
Get-ChildItem C:\Tools\cadre-attack\rubeus-src -Recurse -Filter *.cs | Select-Object -ExpandProperty FullName | Out-String -Width 250
Write-Output "=== createnetonly matches ==="
Get-ChildItem C:\Tools\cadre-attack\rubeus-src -Recurse -Filter *.cs | Select-String -Pattern "CreateProcessWithLogonW|createnetonly|NetOnly" | Select-Object Path, LineNumber, Line | Format-Table -AutoSize | Out-String -Width 250
Write-Output "DONE"
