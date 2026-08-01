# Verify reboot actually happened — check boot time / uptime — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$os = Get-WmiObject Win32_OperatingSystem
Write-Output ("LastBootUpTime=" + $os.LastBootUpTime)
Write-Output ("LocalDateTime=" + $os.LocalDateTime)
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Output ("UptimeMinutes=" + [math]::Round($uptime.TotalMinutes,1))
Write-Output 'UPTIME_DONE'
