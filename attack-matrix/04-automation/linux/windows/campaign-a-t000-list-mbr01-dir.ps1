[CmdletBinding()]
param(
    [string]$Server = "192.168.77.22",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!",
    [string]$RemoteDir = "C:\Windows\Temp\cadre-tools"
)
$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username, $securePass)
$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($d) Get-ChildItem $d -ErrorAction SilentlyContinue | Select-Object Name,Length,LastWriteTime } -ArgumentList $RemoteDir
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}
