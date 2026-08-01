Write-Output '=== SMS Setup registry ==='
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Setup' -ErrorAction SilentlyContinue | Select-Object 'Installation Directory','Installation Source','Source Directory','SMS','UI Language' | Format-List
Write-Output '=== all SMS\Setup values ==='
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Setup' -ErrorAction SilentlyContinue).PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { Write-Output ("  " + $_.Name + " = " + $_.Value) }
Write-Output '=== sitecomp log: mp.msi / source ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\Logs\SMS_SiteComponentManager.log' -ErrorAction SilentlyContinue
Get-Content 'C:\Program Files\Microsoft Configuration Manager\Logs\SMS_SiteComponentManager.log' -ErrorAction SilentlyContinue | Select-String -Pattern 'mp.msi|Management Point|SMS_BGB|bgb|Installing|Source|\\SMSSETUP' | Select-Object -Last 20 | ForEach-Object { $_.Line.Substring(0,[Math]::Min(250,$_.Line.Length)) }
Write-Output '=== check common source paths ==='
@('C:\SMSSETUP','D:\SMSSETUP','C:\ConfigMgr','C:\Sources\ConfigMgr','C:\Program Files\Microsoft Configuration Manager\bin\i386') | ForEach-Object { Write-Output ("  " + $_ + " exists=" + (Test-Path $_)) }
Write-Output 'SRC_DONE'
