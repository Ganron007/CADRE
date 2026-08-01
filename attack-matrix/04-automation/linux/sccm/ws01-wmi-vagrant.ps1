# Test MBR02\vagrant DCOM WMI to SMS provider + CMPivot classes — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
$mp = 'mbr02.range.local'
$cred = New-Object System.Management.Automation.PSCredential('MBR02\vagrant', (ConvertTo-SecureString 'vagrant' -AsPlainText -Force))
$ns = 'root\SMS\site_CAD'

Write-Output '=== [1] DCOM WMI as MBR02\vagrant: SMS_Site ==='
try {
  $s = Get-WmiObject -ComputerName $mp -Credential $cred -Namespace $ns -Class SMS_Site -ErrorAction Stop | Select-Object -First 1
  Write-Output ("OK SiteCode=" + $s.SiteCode + " SiteName=" + $s.SiteName + " Version=" + $s.Version)
} catch { Write-Output ("ERROR: " + $_.Exception.Message) }

Write-Output '=== [2] SMS_ClientOperation class + InitiateClientOperationEx method ==='
try {
  $co = Get-WmiObject -ComputerName $mp -Credential $cred -Namespace $ns -Class SMS_ClientOperation -ErrorAction Stop | Select-Object -First 1
  Write-Output ("SMS_ClientOperation OK: " + ($co | Out-String))
} catch { Write-Output ("ERROR: " + $_.Exception.Message) }
try {
  $mo = New-Object System.Management.ManagementClass("\\$mp\$ns:SMS_ClientOperation")
  # use WMI with creds via GetMethodParameters
  $mc = [wmiclass]::new("\\$mp\$ns:SMS_ClientOperation")
  Write-Output ("methods: " + ($mc.Methods | ForEach-Object { $_.Name }) -join ',')
} catch { Write-Output ("ERROR: " + $_.Exception.Message) }

Write-Output '=== [3] SMS_CMPivotStatus class (polling) ==='
try {
  $cs = Get-WmiObject -ComputerName $mp -Credential $cred -Namespace $ns -Class SMS_CMPivotStatus -ErrorAction Stop | Select-Object -First 5
  Write-Output ("SMS_CMPivotStatus rows: " + @($cs).Count)
  foreach ($c in $cs) { Write-Output ("  " + ($c | Out-String)) }
} catch { Write-Output ("ERROR: " + $_.Exception.Message) }
Write-Output 'WMI_TEST_DONE'
