# Kill stuck ccmsetup + relaunch with local source — run from ws01 as svc_naa
$ErrorActionPreference = 'Continue'
$co = New-Object System.Management.ConnectionOptions
$co.Username = 'RANGE\svc_naa'
$co.Password = 'N@A_s3rv1c3!'
$co.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope('\\mbr02.range.local\root\cimv2', $co)
$scope.Connect()
$mc = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('Win32_Process')), $null)
function Exec($cmdline) {
  $mp = $mc.GetMethodParameters('Create')
  $mp['CommandLine'] = $cmdline
  $r = $mc.InvokeMethod('Create', $mp, $null)
  return $r['ReturnValue']
}
Write-Output '=== Kill stuck ccmsetup ==='
Exec 'cmd.exe /c taskkill /F /IM ccmsetup.exe 2>&1'
Start-Sleep -Seconds 3
Write-Output '=== Launch ccmsetup with /source (local client source) ==='
$cmd = 'C:\Windows\CCMSetup\ccmsetup.exe /source:"C:\Program Files\Microsoft Configuration Manager\Client" /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck'
$rc = Exec $cmd
Write-Output ('LAUNCH_RC=' + $rc)
Write-Output '=== Wait 150s for client install ==='
Start-Sleep -Seconds 150
# verify via staged ps1
Exec 'powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\ccm_verify.ps1'
Start-Sleep -Seconds 10
net use \\mbr02.range.local\C$ /user:RANGE\svc_naa 'N@A_s3rv1c3!' 2>&1 | Out-Null
Write-Output '=== ccm_verify.txt ==='
Get-Content '\\mbr02.range.local\C$\Windows\Temp\ccm_verify.txt' -ErrorAction SilentlyContinue
Write-Output '=== ccmsetup.log tail (last 15) ==='
Get-Content '\\mbr02.range.local\C$\Windows\CCMSetup\Logs\ccmsetup.log' -Tail 15 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '<![LOG\[(.*?)\]LOG') { $Matches[1] } }
net use \\mbr02.range.local\C$ /delete 2>&1 | Out-Null
Write-Output 'DONE'
