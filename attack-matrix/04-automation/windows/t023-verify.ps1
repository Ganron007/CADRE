# T023 verify: mount SYSVOL as analyst_cloud via New-PSDrive and check file
$ErrorActionPreference = 'Continue'
$pass = ConvertTo-SecureString 'Cl0ud_An@lyst!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('cadre.local\analyst_cloud', $pass)

Write-Output '=== T023 verify via New-PSDrive ==='
try {
  $drive = New-PSDrive -Name T23 -PSProvider FileSystem -Root '\\192.168.77.10\SYSVOL\cadre.local\Policies' -Credential $cred -ErrorAction Stop
  Write-Output 'PSDRIVE_OK'
  $p = 'T23:\{885EE71C-79CD-4006-B7CF-616B449F745B}\Machine\Preferences\ScheduledTasks'
  if (Test-Path $p) {
    Write-Output 'DIR_EXISTS'
    Get-ChildItem $p | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Output $_ }
  } else {
    Write-Output 'DIR_MISSING'
    # check parent paths
    foreach ($part in @('{885EE71C-79CD-4006-B7CF-616B449F745B}','{885EE71C-79CD-4006-B7CF-616B449F745B}\Machine','{885EE71C-79CD-4006-B7CF-616B449F745B}\Machine\Preferences')) {
      Write-Output "CHECK|$part|$(Test-Path "T23:\$part")"
    }
  }
  Remove-PSDrive T23
} catch {
  Write-Output "PSDRIVE_FAIL|$($_.Exception.Message)"
}
Write-Output 'VERIFY_DONE'
