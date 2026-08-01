# Check CcmExec + CCM logs on mbr02 via WMI — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
$cred = New-Object System.Management.Automation.PSCredential('MBR02\vagrant', (ConvertTo-SecureString 'vagrant' -AsPlainText -Force))
$mp = 'mbr02.range.local'

Write-Output '=== CcmExec service ==='
try {
  $s = Get-WmiObject -ComputerName $mp -Credential $cred -Class Win32_Service -Filter "Name='CcmExec'" -ErrorAction Stop
  Write-Output ("CcmExec State=" + $s.State + " StartMode=" + $s.StartMode + " Path=" + $s.PathName)
} catch { Write-Output ("ERR: " + $_.Exception.Message) }

Write-Output '=== Other CCM services ==='
try {
  $svcs = Get-WmiObject -ComputerName $mp -Credential $cred -Class Win32_Service -Filter "Name LIKE 'CCM%' OR Name LIKE 'SMS%'" -ErrorAction Stop
  foreach ($x in $svcs) { Write-Output ("  " + $x.Name + " = " + $x.State) }
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output 'CCM_CHECK_DONE'
