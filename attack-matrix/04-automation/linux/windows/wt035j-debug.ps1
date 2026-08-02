# 3.5J debug: check WMI-Activity log (5861 ran / 5858 failed) + direct consumer test
$ErrorActionPreference = 'Continue'

# 1. Direct consumer test — does the CommandLineTemplate work as SYSTEM?
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
cmd.exe /c echo DIRECT_TEST %COMPUTERNAME% %TIME% %USERNAME% >> C:\Windows\Temp\cadre-wmi-events.txt
Write-Output "DIRECT_MARKER $(Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt')"
if (Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt') { Get-Content 'C:\Windows\Temp\cadre-wmi-events.txt' | ForEach-Object { Write-Output "DIRECT_LINE|$_" } }

# 2. Current subscription state
$b = Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue | Where-Object { $_.Filter -match 'CADRE35J' }
$f = Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JFilter' }
$c = Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JConsumer' }
Write-Output "STATE_FILTER $($null -ne $f) CONSUMER $($null -ne $c) BINDINGS $($b.Count)"
$b | ForEach-Object { Write-Output "BINDING_REF|$($_.Filter) => $($_.Consumer)" }

# 3. Trigger notepad + wait
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\notepad.exe' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 15
Get-Process -Name notepad -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output "MARKER_AFTER_TRIGGER $(Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt')"
if (Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt') { Get-Content 'C:\Windows\Temp\cadre-wmi-events.txt' -Tail 3 | ForEach-Object { Write-Output "WMI_LINE|$_" } }

# 4. WMI-Activity operational log — last 10 min, EID 5861 (ran) / 5858 (failed)
$since = (Get-Date).AddMinutes(-10)
Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-WMI-Activity/Operational'; StartTime = $since } -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -in 5861, 5858 } |
    Select-Object -First 8 |
    ForEach-Object { Write-Output "WMIACT|$($_.Id)|$($_.TimeCreated.ToString('HH:mm:ss'))|$($_.Message -replace "`r`n", ' ')" }

# 5. Cleanup subscription
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Write-Output 'DEBUG_CLEANUP_DONE'
