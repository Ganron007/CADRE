$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()
$guid = '200f5731-224e-4c6e-8acc-ef0193e47004'

Write-Output "=== UpdateApprovalState InParameters ==="
$class = New-Object System.Management.ManagementClass($scope, "SMS_Scripts", $null)
foreach ($p in $class.Methods["UpdateApprovalState"].InParameters.Properties) {
    Write-Output ("  PARAM {0} : {1} : [{2}]" -f $p.Name, $p.Type, (($p.Qualifiers | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "; "))
}

$inst = New-Object System.Management.ManagementObject($scope, "SMS_Scripts.ScriptGuid='$guid'", $null)
$inst.Get()

foreach ($val in @("Approved", "1", "approve", "Approve")) {
    Write-Output "=== Try ApprovalState='$val' ==="
    try {
        $in = $inst.GetMethodParameters("UpdateApprovalState")
        $in["ApprovalState"] = $val
        $in["Approver"] = "range\svc_sccm"
        $in["Comment"] = ""
        $r = $inst.InvokeMethod("UpdateApprovalState", $in, $null)
        Write-Output "  RETURN=$r"
        $inst.Get()
        Write-Output "  Approval now=$($inst['ApprovalState'])"
        if ($inst['ApprovalState'] -eq 1) { Write-Output "  APPROVED!"; break }
    } catch {
        Write-Output "  FAIL: $($_.Exception.Message)"
        if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
    }
}
Write-Output "DONE"
