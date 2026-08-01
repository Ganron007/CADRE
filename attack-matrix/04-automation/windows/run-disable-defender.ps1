# Launcher for disable-defender-full.ps1 with elevation attempt
$ErrorActionPreference = 'Continue'
$script = 'C:\Tools\cadre-attack\disable-defender-full.ps1'
if (-not (Test-Path $script)) { Write-Output "SCRIPT_MISSING $script"; exit 1 }

# Check if current token is elevated
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$p = New-Object Security.Principal.WindowsPrincipal($id)
$isAdmin = $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Output "IS_ADMIN=$isAdmin"

if ($isAdmin) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $script
} else {
  Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs -Wait -RedirectStandardOutput 'C:\Tools\cadre-attack\disable-defender-out.txt' -RedirectStandardError 'C:\Tools\cadre-attack\disable-defender-err.txt'
  Write-Output "--- STDOUT ---"
  Get-Content 'C:\Tools\cadre-attack\disable-defender-out.txt' -ErrorAction SilentlyContinue
  Write-Output "--- STDERR ---"
  Get-Content 'C:\Tools\cadre-attack\disable-defender-err.txt' -ErrorAction SilentlyContinue
}
Write-Output "LAUNCHER_DONE"
