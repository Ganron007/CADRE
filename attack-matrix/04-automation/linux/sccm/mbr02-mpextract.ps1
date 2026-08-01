Write-Output '=== admin extract mp.msi ==='
$tmp = 'C:\tmp\mp_extract'
New-Item -ItemType Directory -Path $tmp -Force -ErrorAction SilentlyContinue | Out-Null
$mp = 'C:\Program Files\Microsoft Configuration Manager\cd.latest\SMSSETUP\BIN\X64\mp.msi'
if (Test-Path $mp) {
  $p = Start-Process msiexec.exe -ArgumentList "/a `"$mp`" /qn TARGETDIR=`"$tmp`"" -Wait -PassThru -NoNewWindow
  Write-Output ("msiexec exit: " + $p.ExitCode)
} else { Write-Output 'mp.msi NOT FOUND' }
Write-Output '=== extracted: BGB / handler.ashx ==='
Get-ChildItem $tmp -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'BGB|bgb|handler' -or $_.FullName -match 'SMS_BGB' } | ForEach-Object { Write-Output $_.FullName } | Select-Object -First 30
Write-Output '=== extracted top dirs ==='
Get-ChildItem $tmp -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.FullName } | Select-Object -First 20
Write-Output 'EXTRACT_DONE'
