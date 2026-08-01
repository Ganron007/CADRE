$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== SMS_Application instances ==="
$apps = Get-WmiObject -ComputerName mbr02.range.local -Credential (New-Object System.Management.Automation.PSCredential('range\svc_sccm',(ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))) -Namespace "root\SMS\site_CAD" -Class SMS_Application -ErrorAction SilentlyContinue
Write-Output "APP_COUNT=$($apps.Count)"
foreach ($a in $apps) {
    $xml = [string]$a.SDMPackageXML
    Write-Output ("  APP: {0} | CI_ID={1} | XML_LEN={2}" -f $a.LocalizedDisplayName, $a.CI_ID, $xml.Length)
    if ($xml.Length -gt 0) {
        Write-Output "  --- first 500 chars ---"
        Write-Output $xml.Substring(0, [Math]::Min(500, $xml.Length))
    }
}

Write-Output "=== SMS_DeploymentType instances ==="
$dts = Get-WmiObject -ComputerName mbr02.range.local -Credential (New-Object System.Management.Automation.PSCredential('range\svc_sccm',(ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))) -Namespace "root\SMS\site_CAD" -Class SMS_DeploymentType -ErrorAction SilentlyContinue
Write-Output "DT_COUNT=$($dts.Count)"
foreach ($d in $dts) {
    Write-Output ("  DT: {0} | CI_ID={1}" -f $d.LocalizedDisplayName, $d.CI_ID)
}
Write-Output "DONE"
