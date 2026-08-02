# 3.5J test 3c: unfiltered Win32_Process creation query + session context check
$ErrorActionPreference = 'Continue'

Write-Output "CTX_USER $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Write-Output "CTX_SESSION $((Get-Process -Id $PID).SessionId)"

# Unfiltered query (no Name filter) to isolate the condition
$job = Start-Job -ScriptBlock {
    $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_Process'" -Namespace root\cimv2 -ErrorAction SilentlyContinue
    if ($evt) {
        $ti = $evt.TargetInstance
        Write-Output "EVENT_FIRED|$($ti.Name)|PID $($ti.ProcessId)|$($ti.ExecutablePath)"
    } else { Write-Output 'EVENT_NONE' }
}
Start-Sleep -Seconds 4

# Spawn several distinct processes in this session
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 10 127.0.0.1' -ErrorAction SilentlyContinue
Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList '-NoProfile -Command Start-Sleep 10' -ErrorAction SilentlyContinue
Write-Output 'TRIGGERS_SPAWNED'

if (-not (Wait-Job $job -Timeout 25)) {
    Write-Output 'TEMP_SUB_TIMEOUT'
    Stop-Job $job -ErrorAction SilentlyContinue
} else {
    Receive-Job $job | ForEach-Object { Write-Output "TEMP|$_" }
}
Remove-Job $job -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd,powershell -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'TEST3C_DONE'
