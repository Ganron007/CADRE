# Check SCCM component statuses — analyst_t1 (ws01, provider as MBR02\vagrant)
$ErrorActionPreference = 'Continue'
$mp = 'mbr02.range.local'
$cred = New-Object System.Management.Automation.PSCredential('MBR02\vagrant', (ConvertTo-SecureString 'vagrant' -AsPlainText -Force))
$ns = 'root\SMS\site_CAD'

Write-Output '=== SMS_ComponentStatus ==='
try {
  $cs = Get-WmiObject -ComputerName $mp -Credential $cred -Namespace $ns -Class SMS_ComponentStatus -ErrorAction Stop
  Write-Output ("total: " + @($cs).Count)
  $cs | Where-Object { $_.ComponentName -match 'OPERATION|NOTIFICATION|MP_CONTROL|SMS_MP|CLIENT|EXECUTIVE' -or $_.Status -lt 1 } | ForEach-Object {
    Write-Output ("  " + $_.ComponentName + " | Status=" + $_.Status + " | Type=" + $_.Type + " | LastError=" + $_.LastErrorCode)
  }
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output 'COMP2_DONE'
