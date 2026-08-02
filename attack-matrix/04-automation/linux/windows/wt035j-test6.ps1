# 3.5J test 6: bare sub + LogFile, trigger, dump ALL WMI-Activity + System WMI errors
$ErrorActionPreference = 'Continue'

Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName LogFileEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JLogConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue

$mof = @'
#pragma namespace("\\\\.\\root\\subscription")

instance of __EventFilter as $Filter
{
  EventNamespace = "root/cimv2";
  Name = "CADRE35JFilter";
  Query = "SELECT * FROM __InstanceCreationEvent";
  QueryLanguage = "WQL";
};

instance of LogFileEventConsumer as $LogConsumer
{
  Name = "CADRE35JLogConsumer";
  FileName = "C:\\Windows\\Temp\\cadre-wmi-logfile.txt";
  Text = "CADRE35J_EVENT %__RELPATH%";
};

instance of __FilterToConsumerBinding
{
  Filter = $Filter;
  Consumer = $LogConsumer;
};
'@
$mofPath = 'C:\Windows\Temp\cadre-tools\cadre35j7.mof'
Set-Content -Path $mofPath -Value $mof -Encoding ASCII
& 'C:\Windows\System32\wbem\mofcomp.exe' $mofPath 2>&1 | Out-Null
Start-Sleep -Seconds 3

# Trigger multiple times
Remove-Item 'C:\Windows\Temp\cadre-wmi-logfile.txt' -ErrorAction SilentlyContinue
1..3 | ForEach-Object {
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 3 127.0.0.1' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 4
}
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output "LOGFILE_MARKER $(Test-Path 'C:\Windows\Temp\cadre-wmi-logfile.txt')"
if (Test-Path 'C:\Windows\Temp\cadre-wmi-logfile.txt') { Get-Content 'C:\Windows\Temp\cadre-wmi-logfile.txt' -Tail 5 | ForEach-Object { Write-Output "LOG_LINE|$_" } }

# WMI-Activity dump — last 3 min ALL relevant
$since = (Get-Date).AddMinutes(-3)
Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-WMI-Activity/Operational'; StartTime = $since } -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -in 5857, 5858, 5859, 5860, 5861 } |
    Select-Object -First 12 |
    ForEach-Object { $m = $_.Message -replace "`r`n", ' '; Write-Output "WMIACT|$($_.Id)|$($_.TimeCreated.ToString('HH:mm:ss'))|$m" }

# System log WMI errors (last 30 min)
Get-WinEvent -FilterHashtable @{ LogName = 'System'; StartTime = (Get-Date).AddMinutes(-30) } -ErrorAction SilentlyContinue |
    Where-Object { $_.ProviderName -match 'WMI|Winmgmt' } |
    Select-Object -First 6 |
    ForEach-Object { $m = $_.Message -replace "`r`n", ' '; Write-Output "SYSTEM_WMI|$($_.Id)|$m" }

# Winmgmt service state
Get-Service Winmgmt | ForEach-Object { Write-Output "WINMGMT $($_.Status) $($_.StartType)" }

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName LogFileEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JLogConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Remove-Item $mofPath -ErrorAction SilentlyContinue
Write-Output 'TEST6_DONE'
