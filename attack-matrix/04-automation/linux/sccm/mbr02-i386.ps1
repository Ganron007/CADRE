Write-Output '=== bin\i386 contents (top 60) ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\bin\i386' -ErrorAction SilentlyContinue | Select-Object Name | Select-Object -First 60
Write-Output '=== mp.msi present? ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\bin\i386' -Filter '*.msi' -ErrorAction SilentlyContinue | Select-Object Name
Write-Output '=== search bin for bgb/handler/web.config templates ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\bin' -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'bgb|BGB|handler.ashx|_web.config|vdir' } | Select-Object FullName | Select-Object -First 30
Write-Output 'I386_DONE'
