# WT037 CMPivot trigger on WS01 (16777220) via SMS_ClientOperation as MBR02\vagrant — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
$mp = 'mbr02.range.local'
$resourceId = 16777220   # WS01 (working client)
$query = 'LogicalDisk'

$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'MBR02\vagrant'
$opts.Password = 'vagrant'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\$mp\root\SMS\site_CAD", $opts)
$scope.Connect()
Write-Output '[+] connected to provider as MBR02\vagrant'

$base64query = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($query))
$ParametersXML = "<ScriptParameters>" +
  "<ScriptParameter ParameterGroupGuid='' ParameterGroupName='PG_' ParameterName='kustoquery' ParameterDataType='System.String' ParameterVisibility='0' ParameterType='0' ParameterValue='E:RSgwKQ=='/>" +
  "<ScriptParameter ParameterGroupGuid='' ParameterGroupName='PG_' ParameterName='select' ParameterDataType='System.String' ParameterVisibility='0' ParameterType='0' ParameterValue='E:RGV2aWNlOkRldmljZSxMaW5lOk51bWJlcixDb250ZW50OlN0cmluZw=='/>" +
  "<ScriptParameter ParameterGroupGuid='' ParameterGroupName='PG_' ParameterName='wmiquery' GroupClass='' ParameterDataType='System.String' ParameterVisibility='0' ParameterType='0' ParameterValue='E:$base64query'/>" +
  "</ScriptParameters>"
$sha = [Security.Cryptography.SHA256]::Create()
$hashBytes = $sha.ComputeHash([Text.Encoding]::Unicode.GetBytes($ParametersXML))
$ParametersHash = ([BitConverter]::ToString($hashBytes)).Replace('-','').ToLower()
$xml = "<ScriptContent ScriptGuid='7DC6B6F1-E7F6-43C1-96E0-E1D16BC25C14'>" +
  "<ScriptVersion>1</ScriptVersion>" +
  "<ScriptType>0</ScriptType>" +
  "<ScriptHash ScriptHashAlg='SHA256'>e77a6861a7f6fc25753bc9d7ab49c26d2ddfc426f025b902acefc406ae3b3732</ScriptHash>" +
  $ParametersXML +
  "<ParameterGroupHash ParameterHashAlg='SHA256'>$ParametersHash</ParameterGroupHash>" +
  "</ScriptContent>"
$Param = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($xml))
Write-Output "[+] Param for query=$query"

$class = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('SMS_ClientOperation')), $null)
$inParams = $class.GetMethodParameters('InitiateClientOperationEx')
$inParams['Type'] = [uint32]145
$inParams['TargetCollectionID'] = ''
$inParams['TargetResourceIDs'] = [uint32[]]@($resourceId)
$inParams['RandomizationWindow'] = $null
$inParams['Param'] = $Param

Write-Output '[+] Invoking InitiateClientOperationEx (Type=145 CMPivot) on WS01 ...'
$out = $class.InvokeMethod('InitiateClientOperationEx', $inParams, $null)
$opId = $out.Properties['OperationID'].Value
Write-Output ("[+] OperationID=" + $opId)
Write-Output ('CMPIVOT_TRIGGER_WS01_DONE opId=' + $opId)
