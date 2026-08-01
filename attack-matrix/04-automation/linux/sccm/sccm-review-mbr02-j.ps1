# SCCM mbr02 part J — IIS features, SMS Admins group, log dir, AdminService deploy steps in setup log
$ErrorActionPreference = 'Continue'

# 1) Logs present in the SCCM Logs dir
$logs = @(Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\Logs' -Filter '*.log' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
Write-Output ("LOGS=" + ($logs -join ','))

# 2) Setup log: AdminService deployment-relevant steps (not file-copy)
$log = Get-Content 'C:\ConfigMgrSetup.log' -ErrorAction SilentlyContinue
$rel = @($log | Select-String -Pattern 'AdminService|CMRestProvider|administration service' | Where-Object { $_.Line -match 'instal|deploy|create|IIS|app pool|AppPool|bind|certificate|register|fail|error|Enable|disable|WMI|namespace' })
Write-Output ("AS_REL_COUNT=" + $rel.Count)
Write-Output ("AS_REL_LAST=" + (($rel | Select-Object -Last 20 | ForEach-Object { $_.Line }) -join ' | '))

# 3) IIS role features enabled
$feat = @(Get-WindowsOptionalFeature -Online -FeatureName IIS-* -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Enabled' } | Select-Object -ExpandProperty FeatureName)
Write-Output ("IIS_FEATURES=" + ($feat -join ','))

# 4) SMS Admins group membership after reinstall (svc_sccm still a member?)
$g = @(Get-LocalGroupMember -Group 'SMS Admins' -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
Write-Output ("SMS_ADMINS=" + ($g -join ','))

Write-Output "REVIEW_J_DONE"
