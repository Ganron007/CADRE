$ErrorActionPreference = "SilentlyContinue"
$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)
$ns = "root\SMS\site_CAD"

Write-Output "=== SMS_R_System COUNT ==="
$devs = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_R_System -ErrorAction SilentlyContinue
Write-Output "DEVICE_COUNT=$($devs.Count)"
foreach ($d in $devs) {
    Write-Output ("  DEV: {0} | ResID={1} | Client={2} | Site={3}" -f $d.Name, $d.ResourceId, $d.IsClient, $d.SMSAssignedSites)
}

Write-Output "=== SMS_Collection COUNT ==="
$cols = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_Collection -ErrorAction SilentlyContinue
Write-Output "COLLECTION_COUNT=$($cols.Count)"
foreach ($c in $cols) {
    Write-Output ("  COL: {0} | {1} | members={2}" -f $c.CollectionID, $c.Name, $c.MemberCount)
}

Write-Output "=== SMS_SCI_ClientComp (all) ==="
$cc = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_SCI_ClientComp -ErrorAction SilentlyContinue
Write-Output "CLIENTCOMP_COUNT=$($cc.Count)"
foreach ($x in $cc) {
    Write-Output ("  CC: {0} | Flags={1} | ItemName={2}" -f $x.ClientComponentName, $x.Flags, $x.ItemName)
}

Write-Output "=== SMS_TaskSequencePackage COUNT ==="
$ts = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_TaskSequencePackage -ErrorAction SilentlyContinue
Write-Output "TS_COUNT=$($ts.Count)"

Write-Output "=== SMS_BootImagePackage COUNT ==="
$bi = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_BootImagePackage -ErrorAction SilentlyContinue
Write-Output "BOOTIMAGE_COUNT=$($bi.Count)"

Write-Output "=== SMS_Site ==="
$site = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_Site -ErrorAction SilentlyContinue
foreach ($s in $site) { Write-Output ("  SITE: {0} | {1} | {2}" -f $s.SiteCode, $s.ServerName, $s.BuildNumber) }

Write-Output "=== SMS_Identification ==="
$id = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_Identification -ErrorAction SilentlyContinue
foreach ($s in $id) { Write-Output ("  ID: SiteCode={0} SiteName={1} Version={2}" -f $s.SiteCode, $s.SiteName, $s.SiteVersion) }

Write-Output "DONE"
