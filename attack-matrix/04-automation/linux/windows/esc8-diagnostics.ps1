# ESC8 diagnostics — port 445 holder, service states, coercion tools, spooler on dc01
$ErrorActionPreference = "Continue"
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"

Write-Output "=== services on ws01 ==="
Get-Service LanmanServer,Spooler -ErrorAction SilentlyContinue | Format-Table Status,Name,StartType -AutoSize

Write-Output "=== 445 listener owner ==="
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
if ($c) {
  $c | Format-Table LocalAddress,LocalPort,OwningProcess -AutoSize
  Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue | Format-Table Id,ProcessName,Path -AutoSize
} else {
  Write-Output "no listener on 445"
}

Write-Output "=== impacket coercion + relay tools in py scripts ==="
Get-ChildItem "$py\*.py" -Name | Where-Object { $_ -match "printerbug|petitpotam|spoolsample|ntlmrelayx|coerce" } | Sort-Object

Write-Output "=== C:\Tools coercion tools ==="
Get-ChildItem "C:\Tools\cadre-attack\*" -Include "*coerce*","*printer*","*spool*","*dementor*","*petit*" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

Write-Output "=== spooler on dc01 (MS-RPRN reachability) ==="
$sp = Get-Service Spooler -ComputerName dc01.cadre.local -ErrorAction SilentlyContinue
if ($sp) { $sp | Format-Table Status,Name,DisplayName -AutoSize } else { Write-Output "spooler query failed: $($_.Exception.Message)" }

Write-Output "=== certsrv HTTP reachability re-check ==="
try {
  $r = Invoke-WebRequest -Uri "http://dc01.cadre.local/certsrv/certfnsh.asp" -UseBasicParsing -TimeoutSec 8 -UseDefaultCredentials
  Write-Output "HTTP_RC $($r.StatusCode)"
} catch {
  Write-Output "HTTP_ERR $($_.Exception.Message)"
}
