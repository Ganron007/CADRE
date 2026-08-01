# Verify client state on mbr02 with a staged ps1 — run from ws01 as svc_naa
$ErrorActionPreference = 'Continue'
$co = New-Object System.Management.ConnectionOptions
$co.Username = 'RANGE\svc_naa'
$co.Password = 'N@A_s3rv1c3!'
$co.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope('\\mbr02.range.local\root\cimv2', $co)
$scope.Connect()
# Copy verify ps1 to mbr02
net use \\mbr02.range.local\C$ /user:RANGE\svc_naa 'N@A_s3rv1c3!' 2>&1 | Out-Null
Copy-Item 'C:\Windows\Temp\ccm_verify.ps1' '\\mbr02.range.local\C$\Windows\Temp\ccm_verify.ps1' -Force
net use \\mbr02.range.local\C$ /delete 2>&1 | Out-Null
# Run it
$cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\ccm_verify.ps1'
try {
  $mc = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('Win32_Process')), $null)
  $mp = $mc.GetMethodParameters('Create')
  $mp['CommandLine'] = $cmd
  $r = $mc.InvokeMethod('Create', $mp, $null)
  Write-Output ('RUN_RC=' + $r['ReturnValue'])
} catch { Write-Output ('RUN_ERR=' + $_.Exception.Message) }
Start-Sleep -Seconds 8
net use \\mbr02.range.local\C$ /user:RANGE\svc_naa 'N@A_s3rv1c3!' 2>&1 | Out-Null
Write-Output '=== ccm_verify.txt ==='
Get-Content '\\mbr02.range.local\C$\Windows\Temp\ccm_verify.txt' -ErrorAction SilentlyContinue
net use \\mbr02.range.local\C$ /delete 2>&1 | Out-Null
Write-Output 'VERIFY_DONE'
