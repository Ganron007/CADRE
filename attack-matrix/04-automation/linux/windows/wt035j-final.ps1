# 3.5J FINAL: MOF subscription WITHOUT WITHIN (Server 2025 rejects WITHIN polling) — full E2E
$ErrorActionPreference = 'Continue'

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue

# MOF — no WITHIN clause (event provider push)
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
$mofPath = 'C:\Windows\Temp\cadre-tools\cadre35j3.mof'
Set-Content -Path $mofPath -Value $mof -Encoding ASCII
& 'C:\Windows\System32\wbem\mofcomp.exe' $mofPath 2>&1 | Select-String -Pattern 'successfully parsed|Done|error|fail' | ForEach-Object { Write-Output "MOFCOMP|$_" }
Start-Sleep -Seconds 3

$f = Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JFilter' }
$c = Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JConsumer' }
$b = Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue | Where-Object { $_.Filter -match 'CADRE35J' }
Write-Output "OBJ_FILTER $($null -ne $f) CONSUMER $($null -ne $c) BINDINGS $($b.Count)"

# Trigger + verify
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 6 127.0.0.1' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 12
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
$markerHit = Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt'
Write-Output "WMI_MARKER_HIT $markerHit"
if ($markerHit) { Get-Content 'C:\Windows\Temp\cadre-wmi-events.txt' -Tail 5 | ForEach-Object { Write-Output "WMI_EVENT_LOG|$_" } }

# WMI-Activity: any consumer-run or failure
$since = (Get-Date).AddMinutes(-3)
Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-WMI-Activity/Operational'; StartTime = $since } -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -in 5861, 5858, 5859 } |
    Select-Object -First 6 |
    ForEach-Object { Write-Output "WMIACT|$($_.Id)|$($_.TimeCreated.ToString('HH:mm:ss'))" }

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Remove-Item $mofPath -ErrorAction SilentlyContinue
Write-Output 'FINAL_CLEANUP_DONE'
