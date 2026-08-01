Write-Output '=== C:\Windows\CCM exists? ==='
Test-Path 'C:\Windows\CCM'
if (Test-Path 'C:\Windows\CCM') { Get-ChildItem 'C:\Windows\CCM' -ErrorAction SilentlyContinue | Select-Object Name, LastWriteTime | Select-Object -First 15 }
Write-Output '=== C:\Windows\CCMSetup exists? ==='
Test-Path 'C:\Windows\CCMSetup'
Write-Output '=== ccmsetup.log tail ==='
Get-Content 'C:\Windows\CCMSetup\Logs\ccmsetup.log' -Tail 25 -ErrorAction SilentlyContinue
Write-Output '=== SMS_CCM folder ==='
Get-ChildItem 'C:\Program Files\SMS_CCM' -ErrorAction SilentlyContinue | Select-Object Name | Select-Object -First 20
Write-Output '=== client GUID in registry ==='
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM\SMSCFG' -ErrorAction SilentlyContinue | Select-Object SiteCode, SMSMP, ClientGUID
Write-Output 'DEEP_DONE'
