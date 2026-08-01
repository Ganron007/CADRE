# Complete ConfigMgr client on mbr02 via ManagementScope (proven pattern) — run from ws01 as svc_naa
$ErrorActionPreference = 'Continue'
$co = New-Object System.Management.ConnectionOptions
$co.Username = 'RANGE\svc_naa'
$co.Password = 'N@A_s3rv1c3!'
$co.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope('\\mbr02.range.local\root\cimv2', $co)
try { $scope.Connect(); Write-Output 'SCOPE_CONNECTED' } catch { Write-Output ('SCOPE_ERR=' + $_.Exception.Message); exit 1 }

# 1. Locate ccmsetup.exe
$found = ''
foreach ($cand in @('C:\Windows\CCMSetup\ccmsetup.exe','C:\Windows\ccmsetup.exe','C:\Program Files\Microsoft Configuration Manager\Client\ccmsetup.exe','C:\Windows\System32\ccmsetup.exe')) {
  try {
    $esc = $cand.Replace('\','\\')
    $q = New-Object System.Management.ObjectQuery("SELECT * FROM CIM_DataFile WHERE Name='$esc'")
    $s = New-Object System.Management.ManagementObjectSearcher($scope, $q)
    foreach ($o in $s.Get()) { if ($o['Exists'] -eq $true) { $found = $cand } }
  } catch {}
  if ($found) { break }
}
Write-Output ('CCMSETUP_EXE=' + $found)

# 2. Create process: ccmsetup with site code + MP
$cmd = $found + ' /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck'
try {
  $mc = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('Win32_Process')), $null)
  $mp = $mc.GetMethodParameters('Create')
  $mp['CommandLine'] = $cmd
  $r = $mc.InvokeMethod('Create', $mp, $null)
  Write-Output ('LAUNCH_RC=' + $r['ReturnValue'] + ' PID=' + $r['ProcessId'])
} catch { Write-Output ('LAUNCH_ERR=' + $_.Exception.Message) }
Write-Output 'CLIENT_COMPLETE_LAUNCHED'
