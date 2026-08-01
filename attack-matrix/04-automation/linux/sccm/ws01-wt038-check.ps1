# WT038 check: verify deployment state + markers on WS01
$p1 = 'C:\Windows\Temp\wt038-system.txt'
$p2 = 'C:\Windows\Temp\wt038-marker.txt'
Write-Output ("markers sys=" + (Test-Path $p1) + " marker=" + (Test-Path $p2))
if (Test-Path $p1) { Write-Output '--- wt038-system.txt ---'; Get-Content $p1 }
if (Test-Path $p2) { Write-Output '--- wt038-marker.txt ---'; Get-Content $p2 }

Write-Output '--- CCM_Application (client SDK) ---'
Get-WmiObject -Namespace root\ccm\clientsdk -Class CCM_Application -ErrorAction SilentlyContinue | Select-Object Name, Id, AppDTId | Format-List

Write-Output '--- CCM_ApplicationCIAssignment ---'
Get-WmiObject -Namespace root\ccm\clientsdk -Class CCM_ApplicationCIAssignment -ErrorAction SilentlyContinue | Select-Object AssignmentID, AssignmentName, DPLocality, IsAssigned | Format-List

Write-Output '--- AppEnforce.log tail ---'
if (Test-Path 'C:\Windows\CCM\Logs\AppEnforce.log') { Get-Content 'C:\Windows\CCM\Logs\AppEnforce.log' -Tail 40 }

Write-Output '--- AppDiscovery.log tail ---'
if (Test-Path 'C:\Windows\CCM\Logs\AppDiscovery.log') { Get-Content 'C:\Windows\CCM\Logs\AppDiscovery.log' -Tail 20 }

Write-Output '--- PolicyAgent.log tail ---'
if (Test-Path 'C:\Windows\CCM\Logs\PolicyAgent.log') { Get-Content 'C:\Windows\CCM\Logs\PolicyAgent.log' -Tail 20 }
