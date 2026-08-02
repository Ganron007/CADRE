# 3.5J test 3b: temp subscription FIRST, then trigger — correct ordering
$ErrorActionPreference = 'Continue'

Write-Output 'TEMP_SUB_START'
$job = Start-Job -ScriptBlock {
    $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'cmd.exe'" -Namespace root\cimv2 -ErrorAction SilentlyContinue
    if ($evt) {
        $ti = $evt.TargetInstance
        Write-Output "EVENT_FIRED|$($ti.Name)|PID $($ti.ProcessId)|$($ti.ExecutablePath)"
    } else {
        Write-Output 'EVENT_NONE'
    }
}

# Let the subscription register + first poll cycle complete
Start-Sleep -Seconds 4

# NOW spawn the trigger
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 12 127.0.0.1' -ErrorAction SilentlyContinue
Write-Output 'TRIGGER_SPAWNED'

if (-not (Wait-Job $job -Timeout 25)) {
    Write-Output 'TEMP_SUB_TIMEOUT'
    Stop-Job $job -ErrorAction SilentlyContinue
} else {
    Receive-Job $job | ForEach-Object { Write-Output "TEMP|$_" }
}
Remove-Job $job -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'TEMP_SUB_DONE'
