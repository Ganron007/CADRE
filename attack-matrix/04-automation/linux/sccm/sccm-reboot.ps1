# Reboot mbr02 (MSI pending rename operations — return code 7 demanded this) — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Write-Output '=== Reboot mbr02 ==='
shutdown /r /t 5 /c "CADRE client install reboot" /f
Write-Output 'REBOOT_SCHEDULED'
