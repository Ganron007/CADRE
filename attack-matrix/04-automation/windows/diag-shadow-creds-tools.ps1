# Diagnostic - what can run in-script on ws01 for shadow credentials
Write-Output '=== WHISKER HELP ==='
& 'C:\Tools\cadre-attack\Whisker.exe' /? 2>&1 | Select-Object -First 15
Write-Output '=== RUBEUS SHADOW ==='
& 'C:\Tools\cadre-attack\Rubeus.exe' shadow /help 2>&1 | Select-Object -First 12
Write-Output '=== PYTHON ==='
python --version 2>&1
py --version 2>&1
Write-Output '=== DSINTERNALS IMPORT ==='
Import-Module 'C:\Tools\cadre-attack\DSInternals_v4.7\DSInternals\DSInternals.PowerShell.dll' -ErrorAction SilentlyContinue
$m = Get-Module DSInternals
if ($m) { Write-Output "DSINTERNALS_LOADED|$($m.Version)"; (Get-Command -Module DSInternals).Name | Select-String -Pattern 'KeyCredential|Key|ADKey' | Select-Object -First 10 } else { Write-Output 'DSINTERNALS_NOT_LOADED' }
Write-Output '=== ADMODULE ==='
Import-Module 'C:\Tools\cadre-attack\ADModule-master\ActiveDirectory\Microsoft.ActiveDirectory.Management.dll' -ErrorAction SilentlyContinue
Get-Module ActiveDirectory* -ErrorAction SilentlyContinue | Select-Object Name
Write-Output 'DIAG_DONE'
