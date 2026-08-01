Write-Output '=== SMS_BGB folder ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\SMS_BGB' -Recurse -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 30
Write-Output '=== handler.ashx content ==='
Get-Content 'C:\Program Files\SMS_CCM\SMS_BGB\handler.ashx' -ErrorAction SilentlyContinue
Write-Output '=== IIS .ashx handler in BGB ==='
Import-Module WebAdministration -ErrorAction SilentlyContinue
Get-WebHandler -Location 'IIS:\Sites\Default Web Site\BGB' -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*ashx*' } | Select-Object Name, Path, Modules
Write-Output '=== web.config BGB ==='
Get-Content 'C:\Program Files\SMS_CCM\SMS_BGB\web.config' -ErrorAction SilentlyContinue | Select-Object -First 40
Write-Output '=== test handler.ashx local ==='
try { $r = Invoke-WebRequest -Uri 'http://localhost/bgb/handler.ashx?RequestType=LogIn' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop; Write-Output ("OK " + $r.StatusCode + " len=" + $r.Content.Length) } catch { $c=0; if ($_.Exception.Response) { $c=[int]$_.Exception.Response.StatusCode }; Write-Output ("HTTP " + $c) }
Write-Output 'BGB2_DONE'
