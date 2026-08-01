# SCCM mbr02 — version check (SMS setup registry + binary versions)
$ErrorActionPreference = 'Continue'
$s = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Setup' -ErrorAction SilentlyContinue
if ($s) { Write-Output ("SETUP_ALL=" + (($s.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object { $_.Name + '=' + $_.Value }) -join '|')) } else { Write-Output "SETUP_KEY=NONE" }
$dll = 'C:\Program Files\Microsoft Configuration Manager\bin\x64\base\smscore.dll'
if (Test-Path $dll) { Write-Output ("CORE_VER=" + (Get-Item $dll).VersionInfo.FileVersion) } else { Write-Output "CORE_DLL=MISSING" }
$exe = 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.exe'
if (Test-Path $exe) { Write-Output ("CONSOLE_VER=" + (Get-Item $exe).VersionInfo.FileVersion) } else { Write-Output "CONSOLE_EXE=MISSING" }
Write-Output "VERSION_DONE"
