# Check ws01 admin rights, SpoolSample availability, dc01 spooler state
$ErrorActionPreference = "Continue"
Write-Output "=== identity ==="
whoami
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
Write-Output "is_admin=$($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"
Write-Output "is_domain_admin_check=$($principal.IsInRole('CADRE\Domain Admins'))"

Write-Output "=== local Administrators group members ==="
try {
  net localgroup Administrators 2>&1
} catch { Write-Output "net localgroup failed: $_" }

Write-Output "=== SpoolSample / coercion tools on ws01 ==="
Get-ChildItem "C:\Tools" -Recurse -Include "SpoolSample*.exe","printerbug*","coercer*" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

Write-Output "=== srv2 stop attempt test (dry, as current user) ==="
sc.exe stop srv2 2>&1
Write-Output "srv2_stop_rc=$LASTEXITCODE"
sc.exe start srv2 2>&1 | Out-Null

Write-Output "=== dc01 spooler via WMI ==="
try {
  $s = Get-WmiObject -Class Win32_Service -ComputerName dc01.cadre.local -Filter "Name='Spooler'" -ErrorAction Stop
  $s | Format-List Name,State,StartMode
} catch { Write-Output "wmi_failed: $($_.Exception.Message)" }
