# 3.5J test 2: cmd.exe trigger (known-good) + full WMIACT trace
$ErrorActionPreference = 'Continue'

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue

# MOF with cmd.exe trigger
$mof = @'
#pragma namespace("\\\\.\\root\\subscription")

instance of __EventFilter as $Filter
{
  EventNamespace = "root/cimv2";
  Name = "CADRE35JFilter";
  Query = "SELECT * FROM __InstanceCreationEvent WITHIN 3 WHERE TargetInstance ISA \"Win32_Process\" AND TargetInstance.Name = \"cmd.exe\"";
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
$mofPath = 'C:\Windows\Temp\cadre-tools\cadre35j2.mof'
Set-Content -Path $mofPath -Value $mof -Encoding ASCII
& 'C:\Windows\System32\wbem\mofcomp.exe' $mofPath 2>&1 | Select-String -Pattern 'successfully parsed|Done|error' | ForEach-Object { Write-Output "MOFCOMP|$_" }
Start-Sleep -Seconds 3

# Confirm
$f = Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JFilter' }
$c = Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JConsumer' }
$b = Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue | Where-Object { $_.Filter -match 'CADRE35J' }
Write-Output "OBJ_FILTER $($null -ne $f) CONSUMER $($null -ne $c) BINDINGS $($b.Count)"

# Trigger: long-lived cmd (ping ~10s)
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 10 127.0.0.1' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 20
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Output "MARKER $(Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt')"
if (Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt') { Get-Content 'C:\Windows\Temp\cadre-wmi-events.txt' -Tail 5 | ForEach-Object { Write-Output "WMI_LINE|$_" } }

# Full WMIACT trace around trigger
$since = (Get-Date).AddMinutes(-5)
Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-WMI-Activity/Operational'; StartTime = $since } -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -in 5859, 5860, 5861, 5857 } |
    Select-Object -First 10 |
    ForEach-Object { Write-Output "WMIACT|$($_.Id)|$($_.TimeCreated.ToString('HH:mm:ss'))" }

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Remove-Item $mofPath -ErrorAction SilentlyContinue
Write-Output 'TEST2_CLEANUP_DONE'
