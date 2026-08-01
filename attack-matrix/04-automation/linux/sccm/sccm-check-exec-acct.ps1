# Verify SMS_EXECUTIVE service account + fix if still svc_sccm
$ErrorActionPreference = 'Continue'
Write-Output ("EXEC_ACCT_NOW=" + ((sc.exe qc SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
Write-Output ("SCM_ACCT_NOW=" + ((sc.exe qc SMS_SITE_COMPONENT_MANAGER | Out-String) -replace "`r`n",' | '))
Write-Output "CHECK_DONE"
