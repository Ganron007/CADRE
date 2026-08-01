# SCCM mbr02 part P — REST provider account + auth errors + cert/bind state
$ErrorActionPreference = 'Continue'

Write-Output ("SMS_EXECUTIVE_ACCT=" + ((sc.exe qc SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
Write-Output ("SMS_REST_ACCT=" + ((sc.exe qc SMS_REST_PROVIDER 2>&1 | Out-String) -replace "`r`n",' | '))

$log = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $log) {
    $auth = @(Get-Content $log -ErrorAction SilentlyContinue | Select-String -Pattern '401|Unauthorized|auth|Kerberos|NTLM|Negotiate|certificate|thumbprint|bind|Error|fail|Fail' | Select-Object -Last 20)
    Write-Output ("RESTPROV_AUTH=" + (($auth | ForEach-Object { $_.Line }) -join ' | '))
}

$procs = @(Get-Process -Name 'SCCMProviderGraph','smsexec','SMS_REST*' -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName + ':' + $_.Id })
Write-Output ("PROCS=" + ($procs -join ','))

Write-Output "REVIEW_P_DONE"
