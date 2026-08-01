# Launch ccmsetup to complete the client on mbr02 + verify — run from ws01 as svc_naa
$ErrorActionPreference = 'Continue'
$co = New-Object System.Management.ConnectionOptions
$co.Username = 'RANGE\svc_naa'
$co.Password = 'N@A_s3rv1c3!'
$co.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope('\\mbr02.range.local\root\cimv2', $co)
$scope.Connect()
$cmd = 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck'
try {
  $mc = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('Win32_Process')), $null)
  $mp = $mc.GetMethodParameters('Create')
  $mp['CommandLine'] = $cmd
  $r = $mc.InvokeMethod('Create', $mp, $null)
  Write-Output ('LAUNCH_RC=' + $r['ReturnValue'] + ' PID=' + $r['ProcessId'])
} catch { Write-Output ('LAUNCH_ERR=' + $_.Exception.Message) }
Write-Output '=== Waiting 120s for client to install/assign ==='
Start-Sleep -Seconds 120
# Verify client state
$chk = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-Service CcmExec -EA SilentlyContinue).Status; (Get-ItemProperty ''HKLM:\SOFTWARE\Microsoft\CCM'' -EA SilentlyContinue).AssignedSiteCode; (Get-ItemProperty ''HKLM:\SOFTWARE\Microsoft\CCM'' -EA SilentlyContinue).MP; Test-Path C:\Windows\CCM" > C:\Windows\Temp\ccm_verify.txt 2>&1'
try {
  $mc2 = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('Win32_Process')), $null)
  $mp2 = $mc2.GetMethodParameters('Create')
  $mp2['CommandLine'] = $chk
  $r2 = $mc2.InvokeMethod('Create', $mp2, $null)
  Write-Output ('VERIFY_LAUNCH_RC=' + $r2['ReturnValue'])
} catch { Write-Output ('VERIFY_ERR=' + $_.Exception.Message) }
Start-Sleep -Seconds 10
try {
  net use \\mbr02.range.local\C$ /user:RANGE\svc_naa 'N@A_s3rv1c3!' 2>&1 | Out-Null
  Write-Output '=== ccm_verify.txt ==='
  Get-Content '\\mbr02.range.local\C$\Windows\Temp\ccm_verify.txt' -ErrorAction Stop
  net use \\mbr02.range.local\C$ /delete 2>&1 | Out-Null
} catch { Write-Output ('READ_ERR=' + $_.Exception.Message) }
Write-Output 'CLIENT_VERIFY_DONE'
