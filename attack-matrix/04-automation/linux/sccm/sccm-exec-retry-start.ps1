# Diagnose + retry SMS_EXECUTIVE start under svc_sccm
$ErrorActionPreference = 'Continue'

$ev = @(Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Service Control Manager'} -MaxEvents 40 -ErrorAction SilentlyContinue | Where-Object { $_.Message -match 'SMS_EXECUTIVE|smsexec' } | Select-Object -First 6)
foreach ($e in $ev) { Write-Output ("EVENT=" + $e.Id + " : " + (($e.Message -replace "`r?`n",' | '))) }

& sc.exe start SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 25
Write-Output ("EXEC_STATE=" + ((sc.exe query SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
$p = @(Get-Process -Name smsexec -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
Write-Output ("SMSEXEC_PROCS=" + ($p -join ','))

$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) { Write-Output ("RESTPROV_TAIL=" + ((Get-Content $rp -Tail 10 -ErrorAction SilentlyContinue) -join ' | ')) }

Write-Output "RETRY_DONE"
