$ErrorActionPreference = "SilentlyContinue"
Write-Output "=== C:\Tools\cadre-attack ==="
Get-ChildItem C:\Tools\cadre-attack -Name | Sort-Object
Write-Output "=== Python scripts dir ==="
Get-ChildItem "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts" -Name 2>&1 | Sort-Object
Write-Output "=== certipy check ==="
python -c "import certipy; print('certipy_installed')" 2>&1
python -c "import certipy_ad; print('certipy_ad_installed')" 2>&1
Write-Output "=== C:\Tools dirs ==="
Get-ChildItem C:\Tools -Directory -Name 2>&1 | Sort-Object
Write-Output "=== Rubeus / Certify / SharpSCCM search ==="
Get-ChildItem C:\Tools -Recurse -Filter "*.exe" -Name 2>&1 | Select-String -Pattern "Rubeus|Certify|SharpSCCM|pkinittools|pywhisker" | Sort-Object
Write-Output "=== openssl check ==="
openssl version 2>&1
