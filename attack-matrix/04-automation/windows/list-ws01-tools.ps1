Get-ChildItem C:\Tools\cadre-attack, C:\Tools\ADTools -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
Write-Output "---"
Get-ChildItem C:\Tools -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
