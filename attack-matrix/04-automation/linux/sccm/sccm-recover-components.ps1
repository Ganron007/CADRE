# Recovery: clean restart of component manager + executive to re-init site components (incl. REST provider)
$ErrorActionPreference = 'Continue'
& sc.exe stop SMS_SITE_COMPONENT_MANAGER | Out-Null
& sc.exe stop SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 8
& sc.exe start SMS_SITE_COMPONENT_MANAGER | Out-Null
Start-Sleep -Seconds 8
& sc.exe start SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 60
Write-Output ("SCM_STATE=" + ((sc.exe query SMS_SITE_COMPONENT_MANAGER | Out-String) -replace "`r`n",' | '))
Write-Output ("EXEC_STATE=" + ((sc.exe query SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
$p = @(Get-Process -Name smsexec,SCCMProviderGraph -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName + ':' + $_.Id })
Write-Output ("PROCS=" + ($p -join ','))
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) { Write-Output ("RESTPROV_LAST=" + (Get-Item $rp).LastWriteTime) }
Write-Output "RECOVERY_DONE"
