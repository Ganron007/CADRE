# Confirm REST provider fully started after SMS_EXECUTIVE account change
$ErrorActionPreference = 'Continue'
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
Write-Output ("RESTPROV_TAIL=" + ((Get-Content $rp -Tail 15 -ErrorAction SilentlyContinue) -join ' | '))
$nl = netstat -ano | findstr ":443"
Write-Output ("NETSTAT_443=" + ($nl -join ' | '))
$procs = @(Get-Process -Name SCCMProviderGraph,smsexec -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName + ':' + $_.Id })
Write-Output ("PROCS=" + ($procs -join ','))
# who owns smsexec now (identity check via handle? simpler: tasklist /v)
Write-Output "CHECK_DONE"
