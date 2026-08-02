# 3.5J test 3d: same but surface errors, no SilentlyContinue
$ErrorActionPreference = 'Continue'

$job = Start-Job -ScriptBlock {
    $ErrorActionPreference = 'Continue'
    try {
        $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_Process'" -Namespace root\cimv2 -ErrorAction Stop
        if ($evt) {
            $ti = $evt.TargetInstance
            Write-Output "EVENT_FIRED|$($ti.Name)|PID $($ti.ProcessId)"
        } else { Write-Output 'EVENT_NONE' }
    } catch {
        Write-Output "EVENT_ERROR|$($_.Exception.Message)"
    }
}
Start-Sleep -Seconds 4
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 10 127.0.0.1' -ErrorAction SilentlyContinue
Write-Output 'TRIGGER_SPAWNED'
if (-not (Wait-Job $job -Timeout 25)) {
    Write-Output 'TEMP_SUB_TIMEOUT'
    Stop-Job $job -ErrorAction SilentlyContinue
} else {
    Receive-Job $job | ForEach-Object { Write-Output "TEMP|$_" }
}
Remove-Job $job -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'TEST3D_DONE'
