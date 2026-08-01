# REVERT SMS_EXECUTIVE to LocalSystem (restore site health after the svc_sccm attempt)
$ErrorActionPreference = 'Continue'
& sc.exe config SMS_EXECUTIVE obj= "LocalSystem" password= "" | Out-Null
& sc.exe stop SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 8
& sc.exe start SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 45
Write-Output ("EXEC_STATE=" + ((sc.exe query SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
$p = @(Get-Process -Name smsexec,SCCMProviderGraph -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName + ':' + $_.Id })
Write-Output ("PROCS=" + ($p -join ','))
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) {
    Write-Output ("RESTPROV_LAST_TS=" + (Get-Item $rp).LastWriteTime)
    Write-Output ("RESTPROV_TAIL=" + ((Get-Content $rp -Tail 8 -ErrorAction SilentlyContinue) -join ' | '))
}
Write-Output "REVERT_DONE"
