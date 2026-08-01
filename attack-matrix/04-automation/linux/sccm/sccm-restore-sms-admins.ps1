# SCCM mbr02 part O — restore SMS Admins surface membership (wiped by reinstall) + verify
$ErrorActionPreference = 'Continue'

$members = @('RANGE\svc_sccm', 'CADRE\chief_command', 'CADRE\analyst_purple')
foreach ($m in $members) {
    try {
        Add-LocalGroupMember -Group 'SMS Admins' -Member $m -ErrorAction Stop
        Write-Output ("ADDED=" + $m)
    } catch {
        Write-Output ("ADD_FAIL=" + $m + " : " + $_.Exception.Message)
    }
}

$g = @(Get-LocalGroupMember -Group 'SMS Admins' -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
Write-Output ("SMS_ADMINS_NOW=" + ($g -join ','))

Write-Output "REVIEW_O_DONE"
