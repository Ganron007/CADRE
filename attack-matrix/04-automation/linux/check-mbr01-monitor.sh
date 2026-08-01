#!/bin/bash
NXC=/tmp/nxc-venv/bin/nxc
CMD='
$ErrorActionPreference = "Continue";
$t = "C:\Windows\Temp\cadre-tools";
Write-Output ("DIR_EXISTS=" + (Test-Path $t));
if (Test-Path $t) {
  Get-ChildItem $t -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("FILE|" + $_.Name + "|" + $_.Length) }
}
Write-Output ("PAYLOAD=" + (Test-Path (Join-Path $t "campaign-a-t102-start-monitor-payload.ps1")));
Write-Output ("GODPOTATO=" + (Test-Path (Join-Path $t "GodPotato.exe")));
Write-Output ("RUBEUS=" + (Test-Path (Join-Path $t "Rubeus.exe")));
$p = Get-CimInstance Win32_Process -Filter "Name=''Rubeus.exe''" -ErrorAction SilentlyContinue;
if ($p) { Write-Output ("RUBEUS_RUNNING=" + ($p | Measure-Object).Count) } else { Write-Output "RUBEUS_RUNNING=0" }
'
B64=$(printf '%s' "$CMD" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)
echo "=== MBR01 cadre-tools state ==="
$NXC winrm 192.168.77.22 -u 'child\analyst_t1' -p 'T13r_An@lyst!' -X "powershell -NoProfile -EncodedCommand $B64" 2>&1 | grep -E 'DIR_EXISTS|FILE\||PAYLOAD=|GODPOTATO=|RUBEUS|\[+\]|\[-\]' | head -20
echo "DONE"
