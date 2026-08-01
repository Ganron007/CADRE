$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

$class = New-Object System.Management.ManagementClass($scope, "SMS_Scripts", $null)

Write-Output "=== Try 1: CreateScripts with ApprovalState=1 baked in ==="
$guid2 = [guid]::NewGuid().ToString()
$in = $class.Methods["CreateScripts"].InParameters
$in["ScriptGuid"] = $guid2
$in["ScriptName"] = "CADRE-WT039-SiteTakeover2"
$in["Script"] = "Write-Output 'WT039_HELLO2'; whoami"
$in["ScriptType"] = [uint32]0
$in["Timeout"] = [uint32]120
$in["ScriptVersion"] = "1"
$in["ApprovalState"] = [uint32]1
$in["Approver"] = ""
$in["Author"] = "range\svc_sccm"
$in["ScriptDescription"] = "WT039 v2"
$in["Comment"] = ""
$in["ParameterlistXML"] = ""
$in["ParamsDefinition"] = ""
try {
    $ret = $class.InvokeMethod("CreateScripts", $in, $null)
    Write-Output "RETURN=$($ret.ReturnValue) GUID=$guid2"
    $inst2 = New-Object System.Management.ManagementObject($scope, "SMS_Scripts.ScriptGuid='$guid2'", $null)
    $inst2.Get()
    Write-Output "APPROVAL=$($inst2['ApprovalState'])"
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
}

Write-Output "=== Try 2: UpdateApprovalState on first script, Approver empty ==="
$inst = New-Object System.Management.ManagementObject($scope, "SMS_Scripts.ScriptGuid='200f5731-224e-4c6e-8acc-ef0193e47004'", $null)
$inst.Get()
foreach ($av in @("1", "Approved")) {
    try {
        $ip = $inst.GetMethodParameters("UpdateApprovalState")
        $ip["ApprovalState"] = $av
        $ip["Approver"] = ""
        $ip["Comment"] = ""
        $r = $inst.InvokeMethod("UpdateApprovalState", $ip, $null)
        Write-Output "  val='$av' RETURN=$r"
        $inst.Get()
        Write-Output "  APPROVAL now=$($inst['ApprovalState'])"
        if ($inst['ApprovalState'] -eq 1) { Write-Output "  APPROVED!"; break }
    } catch {
        Write-Output "  val='$av' FAIL: $($_.Exception.Message)"
    }
}
Write-Output "DONE"
