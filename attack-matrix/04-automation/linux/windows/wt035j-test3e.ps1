# 3.5J test 3e: query variant diagnostics
$ErrorActionPreference = 'Continue'

# Does the intrinsic event class exist?
Write-Output '=== CLASS CHECK ==='
Get-WmiObject -Namespace root\cimv2 -List -Class __InstanceCreationEvent -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "CLASS_OK $($_.Name)" }
Get-CimClass -Namespace root/cimv2 -ClassName __InstanceCreationEvent -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "CIMCLASS_OK $($_.CimClassName)" }

# Variant A: no WITHIN, no WHERE (provider-pushed intrinsic event)
$jobA = Start-Job -ScriptBlock {
    try {
        $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent" -Namespace root\cimv2 -ErrorAction Stop
        Write-Output "A_FIRED|$($evt.TargetInstance.Name)"
    } catch { Write-Output "A_ERR|$($_.Exception.Message)" }
}
Start-Sleep -Seconds 3
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 6 127.0.0.1' -ErrorAction SilentlyContinue
if (-not (Wait-Job $jobA -Timeout 20)) { Write-Output 'A_TIMEOUT'; Stop-Job $jobA -ErrorAction SilentlyContinue }
else { Receive-Job $jobA | ForEach-Object { Write-Output "A|$_" } }
Remove-Job $jobA -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'A_DONE'

# Variant B: WITHIN 10 + Name filter (canonical, larger interval)
$jobB = Start-Job -ScriptBlock {
    try {
        $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'cmd.exe'" -Namespace root\cimv2 -ErrorAction Stop
        Write-Output "B_FIRED|$($evt.TargetInstance.Name)"
    } catch { Write-Output "B_ERR|$($_.Exception.Message)" }
}
Start-Sleep -Seconds 3
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 8 127.0.0.1' -ErrorAction SilentlyContinue
if (-not (Wait-Job $jobB -Timeout 25)) { Write-Output 'B_TIMEOUT'; Stop-Job $jobB -ErrorAction SilentlyContinue }
else { Receive-Job $jobB | ForEach-Object { Write-Output "B|$_" } }
Remove-Job $jobB -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'B_DONE'

# Variant C: __InstanceOperationEvent (all ops) with WITHIN
$jobC = Start-Job -ScriptBlock {
    try {
        $evt = Get-WmiObject -Query "SELECT * FROM __InstanceOperationEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process'" -Namespace root\cimv2 -ErrorAction Stop
        Write-Output "C_FIRED|$($evt.GetType().Name)|$($evt.TargetInstance.Name)"
    } catch { Write-Output "C_ERR|$($_.Exception.Message)" }
}
Start-Sleep -Seconds 3
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 8 127.0.0.1' -ErrorAction SilentlyContinue
if (-not (Wait-Job $jobC -Timeout 25)) { Write-Output 'C_TIMEOUT'; Stop-Job $jobC -ErrorAction SilentlyContinue }
else { Receive-Job $jobC | ForEach-Object { Write-Output "C|$_" } }
Remove-Job $jobC -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'C_DONE'
Write-Output 'TEST3E_DONE'
