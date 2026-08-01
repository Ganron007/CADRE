$ErrorActionPreference = "SilentlyContinue"
$sec = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$c = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $sec)
Write-Output "=== SMS_R_UnknownSystem instances ==="
$unk = Get-WmiObject -ComputerName mbr02.range.local -Credential $c -Namespace "root\SMS\site_CAD" -Class SMS_R_UnknownSystem -ErrorAction SilentlyContinue
Write-Output "UNKNOWN_SYSTEM_COUNT=$($unk.Count)"
foreach ($u in $unk) {
    Write-Output ("  UNK: {0} | ResourceID={1} | MAC={2}" -f $u.Name, $u.ResourceId, $u.MACAddress)
}
Write-Output "=== SMS_R_System (full) ==="
$sys = Get-WmiObject -ComputerName mbr02.range.local -Credential $c -Namespace "root\SMS\site_CAD" -Class SMS_R_System -ErrorAction SilentlyContinue
foreach ($s in $sys) {
    Write-Output ("  SYS: {0} | ResourceID={1} | Client={2} | Obsolete={3}" -f $s.Name, $s.ResourceId, $s.IsClient, $s.Obsolete)
}
Write-Output "DONE"
