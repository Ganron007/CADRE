[CmdletBinding()]
param()
$ErrorActionPreference = 'Continue'

# Clean up any leftovers from prior run
Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -Filter "Filter='CADRE35JFilter'" -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
Get-WmiObject -Namespace root\subscription -Class __EventFilter -Filter "Name='CADRE35JFilter'" -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer -Filter "Name='CADRE35JConsumer'" -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue

# 1. EventFilter — trigger on notepad.exe process creation (WITHIN 5 = 5s polling)
$filterArgs = @{
    EventNamespace = 'root\cimv2'
    Name = 'CADRE35JFilter'
    Query = 'SELECT * FROM __InstanceCreationEvent WITHIN 5 WHERE TargetInstance ISA "Win32_Process" AND TargetInstance.Name = "notepad.exe"'
    QueryLanguage = 'WQL'
}
$filter = Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Arguments $filterArgs
Write-Output "FILTER $($filter.Name)"

# 2. CommandLineEventConsumer
$consumerArgs = @{
    Name = 'CADRE35JConsumer'
    CommandLineTemplate = "cmd.exe /c echo %COMPUTERNAME% %TIME% %USERNAME% >> C:\Windows\Temp\cadre-wmi-events.txt"
    ExecutablePath = 'C:\Windows\System32\cmd.exe'
}
$consumer = Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer -Arguments $consumerArgs
Write-Output "CONSUMER $($consumer.Name)"

# 3. Binding
$bindingArgs = @{ Filter = $filter; Consumer = $consumer }
$binding = Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding -Arguments $bindingArgs
Write-Output "BINDING created"

# 4. Trigger — launch notepad.exe (system context), wait for polling cycle
Remove-Item 'C:\Windows\Temp\cadre-wmi-events.txt' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\notepad.exe' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 12
Get-Process -Name notepad -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 5. Verify
$markerHit = Test-Path 'C:\Windows\Temp\cadre-wmi-events.txt'
Write-Output "WMI_MARKER_HIT $markerHit"
if ($markerHit) { Get-Content 'C:\Windows\Temp\cadre-wmi-events.txt' -Tail 3 | ForEach-Object { Write-Output "WMI_EVENT_LOG|$_" } }

# 6. Cleanup
Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -Filter "Filter='CADRE35JFilter'" -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
Get-WmiObject -Namespace root\subscription -Class __EventFilter -Filter "Name='CADRE35JFilter'" -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer -Filter "Name='CADRE35JConsumer'" -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
Write-Output 'WMI_CLEANUP_DONE'

$left = Get-WmiObject -Namespace root\subscription -Class __EventFilter -Filter "Name='CADRE35JFilter'" -ErrorAction SilentlyContinue
Write-Output "WMI_FILTER_LEFT $($null -ne $left)"
