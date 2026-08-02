# 3.5J diag2: create sub + trigger + capture FULL 5858 consumer failure message
$ErrorActionPreference = 'Continue'

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue

$mof = @'
#pragma namespace("\\\\.\\root\\subscription")

instance of __EventFilter as $Filter
{
  EventNamespace = "root/cimv2";
  Name = "CADRE35JFilter";
  Query = "SELECT * FROM __InstanceCreationEvent WHERE TargetInstance ISA \"Win32_Process\" AND TargetInstance.Name = \"cmd.exe\"";
  QueryLanguage = "WQL";
};

instance of CommandLineEventConsumer as $Consumer
{
  Name = "CADRE35JConsumer";
  ExecutablePath = "C:\\Windows\\System32\\cmd.exe";
  CommandLineTemplate = "cmd.exe /c echo %COMPUTERNAME% %TIME% %USERNAME% >> C:\\Windows\\Temp\\cadre-wmi-events.txt";
};

instance of __FilterToConsumerBinding
{
  Filter = $Filter;
  Consumer = $Consumer;
};
'@
$mofPath = 'C:\Windows\Temp\cadre-tools\cadre35j4.mof'
Set-Content -Path $mofPath -Value $mof -Encoding ASCII
& 'C:\Windows\System32\wbem\mofcomp.exe' $mofPath 2>&1 | Out-Null
Start-Sleep -Seconds 3

# Trigger
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 6 127.0.0.1' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 12
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output "MARKER $(Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt')"

# FULL 5858 messages (last 5 min)
$since = (Get-Date).AddMinutes(-5)
Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-WMI-Activity/Operational'; StartTime = $since } -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -eq 5858 } |
    Select-Object -First 5 |
    ForEach-Object { Write-Output "FULL5858|$($_.TimeCreated.ToString('HH:mm:ss'))|$($_.Message -replace "`r`n", ' ')" }

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Remove-Item $mofPath -ErrorAction SilentlyContinue
Write-Output 'DIAG2_DONE'
