$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()
$sec = New-Object System.Management.Automation.PSCredential('range\svc_sccm',(ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))

Write-Output "=== Unknown computer class candidates ==="
$classes = Get-WmiObject -ComputerName mbr02.range.local -Credential $sec -Namespace "root\SMS\site_CAD" -List -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "Unknown" } | Select-Object -ExpandProperty Name
$classes | Out-String -Width 200

Write-Output "=== SMS_UnknownMachine instances ==="
$unk = Get-WmiObject -ComputerName mbr02.range.local -Credential $sec -Namespace "root\SMS\site_CAD" -Class SMS_UnknownMachine -ErrorAction SilentlyContinue
Write-Output "UNKNOWN_COUNT=$($unk.Count)"
foreach ($u in $unk) {
    Write-Output ("  UNK: {0} | ResourceID={1} | Mac={2}" -f $u.Name, $u.ResourceId, $u.MacAddresses)
}

Write-Output "=== All Unknown Computers collection members (SMS000US) ==="
$members = Get-WmiObject -ComputerName mbr02.range.local -Credential $sec -Namespace "root\SMS\site_CAD" -Class SMS_CollectionMember -Filter "CollectionID='SMS000US'" -ErrorAction SilentlyContinue
Write-Output "MEMBERS=$($members.Count)"
foreach ($m in $members) {
    Write-Output ("  MEM: {0} | ResourceID={1}" -f $m.Name, $m.ResourceID)
}
Write-Output "=== All Provisioning Devices members (SMS000PS) ==="
$members2 = Get-WmiObject -ComputerName mbr02.range.local -Credential $sec -Namespace "root\SMS\site_CAD" -Class SMS_CollectionMember -Filter "CollectionID='SMS000PS'" -ErrorAction SilentlyContinue
Write-Output "MEMBERS2=$($members2.Count)"
foreach ($m in $members2) {
    Write-Output ("  MEM: {0} | ResourceID={1}" -f $m.Name, $m.ResourceID)
}
Write-Output "DONE"
