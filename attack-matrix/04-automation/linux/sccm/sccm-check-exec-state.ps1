# Check SMS_EXECUTIVE state after account switch + diagnose start failure
$ErrorActionPreference = 'Continue'

Write-Output ("EXEC_STATE=" + ((sc.exe query SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
$p = @(Get-Process -Name smsexec -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
Write-Output ("SMSEXEC_PROCS=" + ($p -join ','))
$rp = @(Get-Process -Name SCCMProviderGraph -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
Write-Output ("SCCMPROVGRAPH_PROCS=" + ($rp -join ','))

# recent smsexec-related errors in smsprov.log / smsexec.log
foreach ($log in @('C:\Program Files\Microsoft Configuration Manager\logs\smsexec.log','C:\Program Files\Microsoft Configuration Manager\logs\smsprov.log','C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log')) {
    if (Test-Path $log) {
        $errs = @(Get-Content $log -Tail 200 -ErrorAction SilentlyContinue | Select-String -Pattern 'fail|error|denied|cannot|access|SQL|login|0x' | Select-Object -Last 8)
        Write-Output ("LOG_" + (Split-Path $log -Leaf) + "_ERR=" + (($errs | ForEach-Object { $_.Line }) -join ' | '))
    }
}

# SQL login check: does svc_sccm have access? (try a quick local SQL query as svc_naa)
try {
    $q = Invoke-Sqlcmd -Query "SELECT name FROM sys.server_principals WHERE name='RANGE\svc_sccm' OR name LIKE '%svc_sccm%'" -ServerInstance "localhost" -ErrorAction Stop -QueryTimeout 10
    Write-Output ("SQL_LOGINS=" + (($q | ForEach-Object { $_.name }) -join ','))
} catch { Write-Output ("SQL_CHECK_ERR=" + $_.Exception.Message) }

Write-Output "CHECK_DONE"
