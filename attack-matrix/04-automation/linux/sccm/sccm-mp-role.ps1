# MP role state + cmdlets for re-provisioning — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== MP-related cmdlets ==='
Get-Command -Module ConfigurationManager -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'CMSiteRole|CMManagementPoint|CMSiteSystemServer' } | ForEach-Object { Write-Output ("  " + $_.Name) }

Write-Output '=== Current site system servers ==='
Get-CMSiteSystemServer -ErrorAction SilentlyContinue | ForEach-Object {
  Write-Output ("  Server: " + $_.ServerName)
  $_.Roles | ForEach-Object { Write-Output ("    Role: " + $_.RoleName) }
}

Write-Output '=== Get-CMSiteRole ==='
try {
  Get-CMSiteRole -SiteCode CAD -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  Role: " + $_.RoleName + " on " + $_.ServerName) }
} catch { Write-Output ("  Get-CMSiteRole ERROR: " + $_.Exception.Message) }

Write-Output '=== root\ccm namespaces currently (needed by MP control mgr) ==='
try {
  $ns = Get-WmiObject -Namespace root\ccm -Class __NAMESPACE -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
  Write-Output ("  root\ccm children: " + ($ns -join ','))
} catch { Write-Output ("  root\ccm ERROR: " + $_.Exception.Message) }

Write-Output '=== Check mpcontrol recent status (did it recover after fresh client created root\ccm?) ==='
Get-Content 'C:\Program Files\Microsoft Configuration Manager\Logs\mpcontrol.log' -Tail 12 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }
Write-Output 'MPROLE_DONE'
