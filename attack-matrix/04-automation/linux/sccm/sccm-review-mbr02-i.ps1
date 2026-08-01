# SCCM mbr02 part I — why AdminService binaries deployed but IIS/WMI app missing
$ErrorActionPreference = 'Continue'

# 1) smscom.log (SMS_SITE_COMPONENT_MANAGER — deploys site system roles incl. AdminService)
$com = 'C:\Program Files\Microsoft Configuration Manager\Logs\smscom.log'
if (Test-Path $com) {
    $tail = @(Get-Content $com -Tail 40 -ErrorAction SilentlyContinue)
    Write-Output ("SMSCOM_TAIL=" + ($tail -join ' | '))
    $as = @($tail | Select-String -Pattern 'AdminService|admin service|RestProvider|CMRestProvider')
    Write-Output ("SMSCOM_ADMINSVC=" + (($as | ForEach-Object { $_.Line }) -join ' | '))
} else { Write-Output "SMSCOM_LOG=MISSING" }

# 2) Full setup log — AdminService lines with ERROR/WARN/FAIL context
$p = 'C:\ConfigMgrSetup.log'
if (Test-Path $p) {
    $log = Get-Content $p -ErrorAction SilentlyContinue
    $aslines = @($log | Select-String -Pattern 'AdminService|admin service|Administration service|CMRestProvider')
    Write-Output ("SETUPLOG_AS_COUNT=" + $aslines.Count)
    $errs = @($aslines | Where-Object { $_.Line -match 'ERROR|WARN|FAIL|fail|error|Skip' } | Select-Object -Last 12)
    Write-Output ("SETUPLOG_AS_ERR=" + (($errs | ForEach-Object { $_.Line }) -join ' | '))
    # last AdminService-ish lines (what happened near the end)
    $last = @($aslines | Select-Object -Last 6)
    Write-Output ("SETUPLOG_AS_LAST=" + (($last | ForEach-Object { $_.Line }) -join ' | '))
}

Write-Output "REVIEW_I_DONE"
