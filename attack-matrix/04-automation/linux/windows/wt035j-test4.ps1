# 3.5J test 4: permanent sub + LogFileEventConsumer (no child process) with WHERE clause
$ErrorActionPreference = 'Continue'

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName LogFileEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JLogConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue

# MOF: filter WITH WHERE clause + LogFileEventConsumer (writes marker, spawns no process)
$mof = @'
#pragma namespace("\\\\.\\root\\subscription")

instance of __EventFilter as $Filter
{
  EventNamespace = "root/cimv2";
  Name = "CADRE35JFilter";
  Query = "SELECT * FROM __InstanceCreationEvent WHERE TargetInstance ISA \"Win32_Process\" AND TargetInstance.Name = \"cmd.exe\"";
  QueryLanguage = "WQL";
};

instance of LogFileEventConsumer as $LogConsumer
{
  Name = "CADRE35JLogConsumer";
  FileName = "C:\\Windows\\Temp\\cadre-wmi-logfile.txt";
  Text = "CADRE35J_EVENT %__RELPATH% %TargetInstance%";
};

instance of __FilterToConsumerBinding
{
  Filter = $Filter;
  Consumer = $LogConsumer;
};
'@
$mofPath = 'C:\Windows\Temp\cadre-tools\cadre35j5.mof'
Set-Content -Path $mofPath -Value $mof -Encoding ASCII
& 'C:\Windows\System32\wbem\mofcomp.exe' $mofPath 2>&1 | Select-String -Pattern 'successfully parsed|Done|error|fail' | ForEach-Object { Write-Output "MOFCOMP|$_" }
Start-Sleep -Seconds 3

$f = Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JFilter' }
$c = Get-CimInstance -Namespace root/subscription -ClassName LogFileEventConsumer -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JLogConsumer' }
$b = Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue | Where-Object { $_.Filter -match 'CADRE35J' }
Write-Output "OBJ_FILTER $($null -ne $f) LOGCONSUMER $($null -ne $c) BINDINGS $($b.Count)"

# Trigger
Remove-Item 'C:\Windows\Temp\cadre-wmi-logfile.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 8 127.0.0.1' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 15
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output "LOGFILE_MARKER $(Test-Path 'C:\Windows\Temp\cadre-wmi-logfile.txt')"
if (Test-Path 'C:\Windows\Temp\cadre-wmi-logfile.txt') { Get-Content 'C:\Windows\Temp\cadre-wmi-logfile.txt' -Tail 5 | ForEach-Object { Write-Output "LOG_LINE|$_" } }

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName LogFileEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JLogConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Remove-Item $mofPath -ErrorAction SilentlyContinue
Write-Output 'TEST4_CLEANUP_DONE'
