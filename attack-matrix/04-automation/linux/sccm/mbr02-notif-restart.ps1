Write-Output '=== pre-restart: SMS_BGB + handler test ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\SMS_BGB' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.FullName }
try { $r = Invoke-WebRequest -Uri 'http://localhost/bgb/handler.ashx?RequestType=LogIn' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop; Write-Output ("HTTP " + $r.StatusCode) } catch { $c=0; if ($_.Exception.Response) { $c=[int]$_.Exception.Response.StatusCode }; Write-Output ("HTTP " + $c) }

Write-Output '=== restart SMS_EXECUTIVE (notification server thread) ==='
Restart-Service SMS_EXECUTIVE -Force -ErrorAction Stop
Write-Output ('SMS_EXECUTIVE restarted at ' + (Get-Date))

Write-Output '=== wait 30s ==='
Start-Sleep -Seconds 30

Write-Output '=== post-restart: SMS_BGB content ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\SMS_BGB' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_.FullName }
Write-Output '=== post-restart: handler test ==='
try { $r = Invoke-WebRequest -Uri 'http://localhost/bgb/handler.ashx?RequestType=LogIn' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop; Write-Output ("HTTP " + $r.StatusCode + " len=" + $r.Content.Length) } catch { $c=0; if ($_.Exception.Response) { $c=[int]$_.Exception.Response.StatusCode }; Write-Output ("HTTP " + $c) }
Write-Output '=== port 10123 listening? ==='
netstat -ano | findstr 10123
Write-Output 'RESTART_DONE'
