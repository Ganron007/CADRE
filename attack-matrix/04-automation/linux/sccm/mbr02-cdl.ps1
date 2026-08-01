Write-Output '=== cd.latest: dirs matching BGB ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\cd.latest' -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'BGB|bgb' } | ForEach-Object { Write-Output $_.FullName }
Write-Output '=== cd.latest: files matching BGB/handler ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\cd.latest' -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'BGB|bgb|handler.ashx' } | ForEach-Object { Write-Output $_.FullName } | Select-Object -First 40
Write-Output '=== cd.latest\SMSSETUP top ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\cd.latest\SMSSETUP' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.FullName } | Select-Object -First 30
Write-Output '=== cd.latest\SMSSETUP\BIN\X64 MSIs ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\cd.latest\SMSSETUP\BIN\X64' -Filter '*.msi' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.Name }
Write-Output 'CDL_DONE'
