# Comprehensive MP-side diagnostic — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$siteLogs = 'C:\Program Files\Microsoft Configuration Manager\Logs'

Write-Output '=== All MP-related logs (any case/name) ==='
Get-ChildItem $siteLogs -Filter '*.log' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '(?i)mp|managementpoint|location|policy' } | Sort-Object LastWriteTime -Descending | Select-Object -First 30 | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.LastWriteTime + " | " + $_.Length) }

Write-Output '=== Get-CMManagementPoint (console module) ==='
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue
try {
  Get-CMManagementPoint -ErrorAction Stop | ForEach-Object {
    Write-Output ("  MP: " + $_.NetworkPath + " | SiteCode=" + $_.SiteCode + " | IsActive=" + $_.IsActive)
    Write-Output ("    UseCloud=" + $_.UseCloud + " ClientConnectionType=" + $_.ClientConnectionType + " ServerName=" + $_.ServerName)
  }
} catch { Write-Output ("  Get-CMManagementPoint ERROR: " + $_.Exception.Message) }

Write-Output '=== MP site system role status ==='
try {
  Get-CMSiteSystemServer -SiteCode CAD -ErrorAction Stop | ForEach-Object { Write-Output ("  SiteSystem: " + $_.ServerName) }
} catch { Write-Output ("  Get-CMSiteSystemServer ERROR: " + $_.Exception.Message) }

Write-Output '=== IIS logs: recent 500s on ccm_system ==='
$iislogs = 'C:\inetpub\logs\LogFiles'
if (Test-Path $iislogs) {
  Get-ChildItem $iislogs -Recurse -Filter '*.log' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-3) } | ForEach-Object {
    Write-Output ("  --- " + $_.Name)
    Get-Content $_.FullName -Tail 200 | Where-Object { $_ -match 'ccm_system|CCM_Client' -and $_ -match ' 500 ' } | Select-Object -Last 8 | ForEach-Object { Write-Output ("    " + $_) }
  }
} else { Write-Output '  no IIS logs dir' }

Write-Output '=== MP-related Windows services (site side) ==='
Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'SMS_MP|CCM|SMS_EXEC|SMS_SITE|sms' -and $_.Name -notmatch 'SQL|Backup' } | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.State) }
Write-Output 'MPDIAG3_DONE'
