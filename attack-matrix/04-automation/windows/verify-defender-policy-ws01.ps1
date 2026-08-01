$ErrorActionPreference = 'Continue'
Write-Output '--- Policy key dump ---'
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -ErrorAction SilentlyContinue | Format-List | Out-String | Write-Output
Write-Output '--- RTP subkey dump ---'
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -ErrorAction SilentlyContinue | Format-List | Out-String | Write-Output
Write-Output '--- SpyNet subkey dump ---'
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet' -ErrorAction SilentlyContinue | Format-List | Out-String | Write-Output
Write-Output '--- Features subkey ---'
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features' -ErrorAction SilentlyContinue | Format-List TamperProtection | Out-String | Write-Output
