# 3.5J test 3: temporary (blocking) event subscription to prove the event fires
$ErrorActionPreference = 'Continue'

Write-Output 'TEMP_SUB_START'
# Spawn a long-lived cmd in background first
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 15 127.0.0.1' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Blocking temporary subscription — should return the cmd.exe creation event
$job = Start-Job -ScriptBlock {
    $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'cmd.exe'" -Namespace root\cimv2 -ErrorAction SilentlyContinue
    if ($evt) {
        $ti = $evt.TargetInstance
        Write-Output "EVENT_FIRED|$($ti.Name)|PID $($ti.ProcessId)|$($ti.ExecutablePath)"
    } else {
        Write-Output 'EVENT_NONE'
    }
}
if (-not (Wait-Job $job -Timeout 25)) {
    Write-Output 'TEMP_SUB_TIMEOUT'
    Stop-Job $job -ErrorAction SilentlyContinue
} else {
    Receive-Job $job | ForEach-Object { Write-Output "TEMP|$_" }
}
Remove-Job $job -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'TEMP_SUB_DONE'
