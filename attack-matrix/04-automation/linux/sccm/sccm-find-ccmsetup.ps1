# Find ccmsetup.exe on mbr02 via dir scan — run from ws01 as svc_naa
$ErrorActionPreference = 'Continue'
$co = New-Object System.Management.ConnectionOptions
$co.Username = 'RANGE\svc_naa'
$co.Password = 'N@A_s3rv1c3!'
$co.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope('\\mbr02.range.local\root\cimv2', $co)
$scope.Connect()
$scan = 'cmd.exe /c (dir /s /b C:\Windows\CCMSetup\*.exe 2^>nul ^& dir /s /b "C:\Program Files\Microsoft Configuration Manager\Client\*.exe" 2^>nul ^& dir /s /b "C:\Program Files\SMS_CCM\*.exe" 2^>nul) > C:\Windows\Temp\ccmsetup_find.txt'
try {
  $mc = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('Win32_Process')), $null)
  $mp = $mc.GetMethodParameters('Create')
  $mp['CommandLine'] = $scan
  $r = $mc.InvokeMethod('Create', $mp, $null)
  Write-Output ('SCAN_RC=' + $r['ReturnValue'])
} catch { Write-Output ('SCAN_ERR=' + $_.Exception.Message) }
Start-Sleep -Seconds 5
# Read the result via SMB
try {
  net use \\mbr02.range.local\C$ /user:RANGE\svc_naa 'N@A_s3rv1c3!' 2>&1 | Out-Null
  Write-Output '=== ccmsetup_find.txt ==='
  Get-Content '\\mbr02.range.local\C$\Windows\Temp\ccmsetup_find.txt' -ErrorAction Stop
  net use \\mbr02.range.local\C$ /delete 2>&1 | Out-Null
} catch { Write-Output ('READ_ERR=' + $_.Exception.Message) }
Write-Output 'FIND_DONE'
