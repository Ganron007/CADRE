$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== SMS_Advertisement.AssignedSchedule qualifiers ==="
$c = New-Object System.Management.ManagementClass($scope, "SMS_Advertisement", $null)
$p = $c.Properties["AssignedSchedule"]
foreach ($q in $p.Qualifiers) { Write-Output ("  {0} = {1}" -f $q.Name, $q.Value) }

Write-Output "=== Schedule-related classes ==="
$classes = Get-WmiObject -ComputerName mbr02.range.local -Credential (New-Object System.Management.Automation.PSCredential('range\svc_sccm',(ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))) -Namespace "root\SMS\site_CAD" -List -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "Schedule|Recurrence" } | Select-Object -ExpandProperty Name
$classes | Out-String -Width 200
Write-Output "DONE"
