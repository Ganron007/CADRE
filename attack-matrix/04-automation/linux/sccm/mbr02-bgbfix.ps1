Write-Output '=== install.map bgb lines ==='
Select-String -Path 'C:\Program Files\Microsoft Configuration Manager\cd.latest\SMSSETUP\install.map' -Pattern 'bgb' -ErrorAction SilentlyContinue | ForEach-Object { $_.Line }
Write-Output '=== install bgbisapi.msi (sitecomp-style) ==='
$msi = 'C:\Program Files\Microsoft Configuration Manager\cd.latest\SMSSETUP\BIN\X64\bgbisapi.msi'
$log = 'C:\Windows\Temp\bgbisapi-install.log'
$p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" SITECODE=CAD SMSDIR=`"C:\Program Files\Microsoft Configuration Manager`" /qn /l*v `"$log`"" -Wait -PassThru -NoNewWindow
Write-Output ("install exit: " + $p.ExitCode)
Write-Output '=== post-install SMS_BGB ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\SMS_BGB' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.FullName }
Write-Output '=== test /bgb/handler.ashx ==='
Start-Sleep -Seconds 3
try { $r = Invoke-WebRequest -Uri 'http://localhost/bgb/handler.ashx?RequestType=LogIn' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop; Write-Output ("HTTP " + $r.StatusCode + " len=" + $r.Content.Length) } catch { $c=0; if ($_.Exception.Response) { $c=[int]$_.Exception.Response.StatusCode }; Write-Output ("HTTP " + $c) }
Write-Output '=== log tail ==='
Get-Content $log -Tail 15 -ErrorAction SilentlyContinue
Write-Output 'BGBINSTALL_DONE'
