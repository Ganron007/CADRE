# Ground truth: did mbr02 reboot? REST provider state?
$ErrorActionPreference = 'Continue'
$os = Get-CimInstance Win32_OperatingSystem
Write-Output ("LAST_BOOT=" + $os.LastBootUpTime)
Write-Output ("UP_MIN=" + [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalMinutes))
$p = @(Get-Process -Name smsexec,SCCMProviderGraph -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName + ':' + $_.Id })
Write-Output ("PROCS=" + ($p -join ','))
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) { Write-Output ("RESTPROV_LAST=" + (Get-Item $rp).LastWriteTime) }
$nl = netstat -ano | findstr ":443"
Write-Output ("NETSTAT_443=" + ($nl -join ' | '))
$exec = 'C:\Program Files\Microsoft Configuration Manager\logs\smsexec.log'
if (Test-Path $exec) { Write-Output ("SMSEXEC_TAIL=" + ((Get-Content $exec -Tail 6 -ErrorAction SilentlyContinue) -join ' | ')) }
Write-Output "GT_DONE"
