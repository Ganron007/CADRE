# PROPER revert: SMS_EXECUTIVE back to LocalSystem (previous attempt failed due to password= "" arg)
$ErrorActionPreference = 'Continue'
$cfg = & sc.exe config SMS_EXECUTIVE obj= "LocalSystem"
Write-Output ("CFG_RESULT=" + ($cfg -join ' | '))
$qc = (sc.exe qc SMS_EXECUTIVE | Out-String)
Write-Output ("EXEC_ACCT_AFTER_CONFIG=" + (($qc -split "`r?`n" | Where-Object { $_ -match 'SERVICE_START_NAME' }) -join ' '))
& sc.exe stop SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 8
& sc.exe start SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 70
Write-Output ("EXEC_STATE=" + ((sc.exe query SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
$p = @(Get-Process -Name smsexec,SCCMProviderGraph -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName + ':' + $_.Id })
Write-Output ("PROCS=" + ($p -join ','))
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) { Write-Output ("RESTPROV_LAST=" + (Get-Item $rp).LastWriteTime) }
Write-Output "FIX_DONE"
