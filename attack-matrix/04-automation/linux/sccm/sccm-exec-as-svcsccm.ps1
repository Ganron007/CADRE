# Close WT037/039 gate: REST provider must run as svc_sccm (SPN owner) to decrypt the CD ticket
# Steps: add administrator to SMS Admins, grant svc_sccm SeServiceLogonRight,
#        switch SMS_EXECUTIVE service account to RANGE\svc_sccm, restart, verify.
$ErrorActionPreference = 'Continue'

# 1) administrator -> SMS Admins (impersonation target must be an SCCM admin)
try {
    Add-LocalGroupMember -Group 'SMS Admins' -Member 'RANGE\administrator' -ErrorAction Stop
    Write-Output "ADMIN_ADDED"
} catch { Write-Output ("ADMIN_ADD_MSG=" + $_.Exception.Message) }

# 2) SeServiceLogonRight for svc_sccm
$cfg = "$env:windir\Temp\cadre-secpol.cfg"
& "$env:windir\System32\secedit.exe" /export /areas USER_RIGHTS /cfg $cfg | Out-Null
$sid = ([System.Security.Principal.NTAccount]"RANGE\svc_sccm").Translate([System.Security.Principal.SecurityIdentifier]).Value
Write-Output ("SVC_SCCM_SID=" + $sid)
$lines = Get-Content $cfg
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^SeServiceLogonRight\s*=' -and $lines[$i] -notmatch [regex]::Escape($sid)) {
        $lines[$i] = $lines[$i].TrimEnd() + ",*$sid"
    }
}
Set-Content $cfg $lines
& "$env:windir\System32\secedit.exe" /configure /db secedit.sdb /cfg $cfg /areas USER_RIGHTS | Out-Null
Remove-Item $cfg -Force
Write-Output "LOGON_RIGHT_GRANTED"

# 3) Switch SMS_EXECUTIVE to svc_sccm
Write-Output ("EXEC_BEFORE=" + ((sc.exe qc SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
& sc.exe config SMS_EXECUTIVE obj= "RANGE\svc_sccm" password= "s3rv1c3_SCCM!" | Out-Null
Write-Output "EXEC_CONFIG_SET"
& sc.exe stop SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 5
& sc.exe start SMS_EXECUTIVE | Out-Null
Start-Sleep -Seconds 20
Write-Output ("EXEC_AFTER=" + ((sc.exe qc SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))
Write-Output ("EXEC_STATE=" + ((sc.exe query SMS_EXECUTIVE | Out-String) -replace "`r`n",' | '))

# 4) REST provider log tail (did it start under the new identity?)
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) {
    Write-Output ("RESTPROV_TAIL=" + ((Get-Content $rp -Tail 12 -ErrorAction SilentlyContinue) -join ' | '))
}

Write-Output "CONFIG_DONE"
