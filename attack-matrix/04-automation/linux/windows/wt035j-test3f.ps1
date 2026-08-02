# 3.5J test 3f: temp sub WITH exact WHERE clause + dump event structure
$ErrorActionPreference = 'Continue'

# Part 1: exact permanent query as TEMP sub
$job = Start-Job -ScriptBlock {
    try {
        $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'cmd.exe'" -Namespace root\cimv2 -ErrorAction Stop
        if ($evt) {
            Write-Output "F_FIRED|class=$($evt.GetType().Name)"
            try { $ti = $evt.TargetInstance; Write-Output "F_TI_NULL $($null -eq $ti) TI_NAME $($ti.Name)" } catch { Write-Output "F_TI_ERR|$($_.Exception.Message)" }
        } else { Write-Output 'F_NONE' }
    } catch { Write-Output "F_ERR|$($_.Exception.Message)" }
}
Start-Sleep -Seconds 4
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 8 127.0.0.1' -ErrorAction SilentlyContinue
if (-not (Wait-Job $job -Timeout 20)) { Write-Output 'F_TIMEOUT'; Stop-Job $job -ErrorAction SilentlyContinue }
else { Receive-Job $job | ForEach-Object { Write-Output "F|$_" } }
Remove-Job $job -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue

# Part 2: no-WHERE temp sub, dump event fully
$job2 = Start-Job -ScriptBlock {
    try {
        $evt = Get-WmiObject -Query "SELECT * FROM __InstanceCreationEvent" -Namespace root\cimv2 -ErrorAction Stop
        Write-Output "G_FIRED|class=$($evt.GetType().Name)"
        $evt.PSObject.Properties | ForEach-Object { Write-Output "G_PROP|$($_.Name)=$($_.Value)" }
        try { $ti = $evt.TargetInstance; Write-Output "G_TI_NULL $($null -eq $ti) TI_TYPE $($ti.GetType().Name) TI_NAME $($ti.Name)" } catch { Write-Output "G_TI_ERR|$($_.Exception.Message)" }
    } catch { Write-Output "G_ERR|$($_.Exception.Message)" }
}
Start-Sleep -Seconds 4
Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList '/c ping -n 8 127.0.0.1' -ErrorAction SilentlyContinue
if (-not (Wait-Job $job2 -Timeout 20)) { Write-Output 'G_TIMEOUT'; Stop-Job $job2 -ErrorAction SilentlyContinue }
else { Receive-Job $job2 | ForEach-Object { Write-Output "G|$_" } }
Remove-Job $job2 -Force -ErrorAction SilentlyContinue
Get-Process -Name cmd -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output 'TEST3F_DONE'
