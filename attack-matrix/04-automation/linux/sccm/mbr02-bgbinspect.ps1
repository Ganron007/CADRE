Write-Output '=== [1] admin-extract bgbisapi.msi to inspect ==='
$tmp = 'C:\tmp\bgb_extract'
New-Item -ItemType Directory -Path $tmp -Force -ErrorAction SilentlyContinue | Out-Null
$msi = 'C:\Program Files\Microsoft Configuration Manager\cd.latest\SMSSETUP\BIN\X64\bgbisapi.msi'
if (Test-Path $msi) {
  $p = Start-Process msiexec.exe -ArgumentList "/a `"$msi`" /qn TARGETDIR=`"$tmp`"" -Wait -PassThru -NoNewWindow
  Write-Output ("extract exit: " + $p.ExitCode)
  Get-ChildItem $tmp -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.FullName } | Select-Object -First 40
} else { Write-Output 'bgbisapi.msi NOT FOUND' }
Write-Output '=== [2] current SMS_BGB before install ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\SMS_BGB' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.FullName }
Write-Output 'EXTRACTBGB_DONE'
