# Check SCCM component statuses — analyst_t1 (ws01, provider as MBR02\vagrant)
$ErrorActionPreference = 'Continue'
$mp = 'mbr02.range.local'
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'MBR02\vagrant'
$opts.Password = 'vagrant'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\$mp\root\SMS\site_CAD", $opts)
try { $scope.Connect(); Write-Output '[+] connected' } catch { Write-Output ("CONN ERR: " + $_.Exception.Message); exit }

Write-Output '=== SMS_ComponentStatus (all, key ones) ==='
try {
  $cs = Get-WmiObject -Class SMS_ComponentStatus -Namespace root\SMS\site_CAD -Scope $scope -ErrorAction Stop
  $cs | Where-Object { $_.ComponentName -match 'OPERATION|NOTIFICATION|MP_CONTROL|SMS_MP|CLIENT' -or $_.Status -lt 1 } | ForEach-Object {
    Write-Output ("  " + $_.ComponentName + " | Status=" + $_.Status + " | Type=" + $_.Type + " | LastError=" + $_.LastErrorCode + " | Msg=" + $_.LastMessage)
  }
  Write-Output ("total components: " + @($cs).Count)
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output 'COMP_DONE'
