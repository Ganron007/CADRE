Write-Output '=== search cd.latest for handler.ashx ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\cd.latest' -Recurse -Filter 'handler.ashx' -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 20
Write-Output '=== search cd.latest for SMS_BGB dirs ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\cd.latest' -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'BGB|bgb' } | Select-Object FullName | Select-Object -First 20
Write-Output '=== search SMSSETUP\BIN\X64 for bgb/vdir ==='
Get-ChildItem 'C:\Windows\Temp\SMSSETUP\BIN\X64' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'bgb|BGB|vdir|handler' } | Select-Object Name | Select-Object -First 20
Write-Output '=== X64 mp.msi + associated files ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\cd.latest\SMSSETUP\BIN\X64' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'mp|MP|bgb|BGB|vdir' } | Select-Object Name | Select-Object -First 30
Write-Output 'BGBSRC_DONE'
