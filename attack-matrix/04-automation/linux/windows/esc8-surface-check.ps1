# ESC8 surface check from ws01
$ErrorActionPreference = "Continue"
Write-Output "=== web enrollment (HTTP) ==="
try {
  $r = Invoke-WebRequest -Uri "http://dc01.cadre.local/certsrv/certfnsh.asp" -UseBasicParsing -TimeoutSec 8 -UseDefaultCredentials
  Write-Output "HTTP_RC $($r.StatusCode)"
} catch {
  $code = $_.Exception.Response.StatusCode.value__
  Write-Output "HTTP_ERR $code $($_.Exception.Message)"
}
try {
  $r2 = Invoke-WebRequest -Uri "http://dc01.cadre.local/certsrv/" -UseBasicParsing -TimeoutSec 8 -UseDefaultCredentials
  Write-Output "CERTSRV_RC $($r2.StatusCode)"
} catch {
  $code = $_.Exception.Response.StatusCode.value__
  Write-Output "CERTSRV_ERR $code $($_.Exception.Message)"
}
Write-Output "=== ntlmrelayx available ==="
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
Get-ChildItem "$py\ntlmrelayx*","$py\petitpotam*","$py\printerbug*","$py\rbcd*","$py\addcomputer*","$py\ntlmrelay*" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
Write-Output "=== SMB port 445 on ws01 ==="
netstat -ano | Select-String ":445 " | Select-Object -First 5
Write-Output "=== LanmanServer service ==="
Get-Service LanmanServer | Select-Object Status, Name
