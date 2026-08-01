Write-Output '=== search mp.msi on C: ==='
Get-ChildItem 'C:\' -Filter 'mp.msi' -Recurse -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime | Select-Object -First 10
Write-Output '=== sitecomp inbox/source ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\inboxes' -Recurse -Filter '*.msi' -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 10
Write-Output '=== sitecomp log: mp install lines ==='
Get-Content 'C:\Program Files\Microsoft Configuration Manager\Logs\SMS_SiteComponentManager.log' -Tail 200 -ErrorAction SilentlyContinue | Select-String -Pattern 'mp.msi|Management Point|Installing|Source|Install' | Select-Object -Last 15 | ForEach-Object { $_.Line.Substring(0,[Math]::Min(300,$_.Line.Length)) }
Write-Output '=== SCCM eval downloader cached? ==='
Get-ChildItem 'C:\Windows\Temp','C:\Users\vagrant','C:\tmp' -Filter 'ConfigMgr*' -Recurse -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 10
Write-Output 'MPFIND_DONE'
