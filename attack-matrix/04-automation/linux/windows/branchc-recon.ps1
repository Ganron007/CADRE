$ErrorActionPreference = "SilentlyContinue"
$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)
$ns = "root\SMS\site_CAD"
function Q($cls, $filter, $props) {
    Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class $cls -Filter $filter -ErrorAction SilentlyContinue | Select-Object $props
}
Write-Output "=== DEVICES (SMS_R_System) ==="
Q SMS_R_System $null "Name,ResourceId,IsClient,SMSAssignedSites" | Format-Table -AutoSize | Out-String -Width 200
Write-Output "=== COLLECTIONS ==="
Q SMS_Collection $null "CollectionID,Name,MemberCount" | Format-Table -AutoSize | Out-String -Width 200
Write-Output "=== CLIENT PUSH (SMS_SCI_ClientComp Software Distribution) ==="
Q SMS_SCI_ClientComp "ClientComponentName = 'Software Distribution'" "Flags,ItemName" | Format-List | Out-String -Width 200
Write-Output "=== PXE CERT INFO (SMS_PXECertificateInfo) ==="
Q SMS_PXECertificateInfo $null "*" | Format-List | Out-String -Width 200
Write-Output "=== BOOT IMAGES (SMS_BootImagePackage) ==="
Q SMS_BootImagePackage $null "PackageID,Name,ImageProperty" | Format-Table -AutoSize | Out-String -Width 200
Write-Output "=== TASK SEQUENCES (SMS_TaskSequencePackage) ==="
Q SMS_TaskSequencePackage $null "PackageID,Name" | Format-Table -AutoSize | Out-String -Width 200
Write-Output "=== SITE INFO (SMS_Site) ==="
Q SMS_Site $null "SiteCode,ServerName,BuildNumber" | Format-Table -AutoSize | Out-String -Width 200
Write-Output "DONE"
