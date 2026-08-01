# Check what still holds 445 after stopping LanmanServer + srv2
$ErrorActionPreference = "Continue"
Write-Output "=== service states ==="
Get-Service LanmanServer,Spooler -ErrorAction SilentlyContinue | Format-Table Status,Name -AutoSize
Write-Output "=== driver states ==="
sc.exe query srv2
sc.exe query srvnet
sc.exe query mrxsmb
Write-Output "=== 445 listener ==="
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
if ($c) {
  $c | Format-Table LocalAddress,LocalPort,OwningProcess -AutoSize
  Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue | Format-Table Id,ProcessName,Path -AutoSize
} else {
  Write-Output "no listener"
}
Write-Output "=== which service depends on srv2 ==="
sc.exe enumdepend srv2
