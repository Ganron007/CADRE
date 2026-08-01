Write-Output '=== search for handler.ashx on mbr02 ==='
Get-ChildItem 'C:\' -Filter 'handler.ashx' -Recurse -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 20
Write-Output '=== search for SMS_BGB dirs ==='
Get-ChildItem 'C:\' -Filter 'SMS_BGB' -Recurse -Directory -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 10
Write-Output '=== ConfigMgr bin i386 vdir templates ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\bin\i386' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'mp.msi|vdir|bgb|BGB' } | Select-Object Name | Select-Object -First 20
Write-Output '=== C:\Windows\CCMSetup or install source with vdirs ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager' -Recurse -Filter 'web.config' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -match 'BGB|bgb' } | Select-Object FullName
Write-Output '=== MP install log for BGB ==='
Get-ChildItem 'C:\Windows\Temp' -Filter '*.log' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'mp|MP' } | Select-Object Name, LastWriteTime
Get-Content 'C:\Windows\Temp\MPSetup.log' -Tail 30 -ErrorAction SilentlyContinue
Write-Output 'SEARCH_DONE'
