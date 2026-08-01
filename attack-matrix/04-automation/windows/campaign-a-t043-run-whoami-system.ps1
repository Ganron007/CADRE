[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"

& 'C:\Tools\cadre-attack\campaign-a-t043-system-exec.ps1' -ScriptBlock 'whoami; whoami /groups | findstr /i "S-1-16-16384"; set COMPUTERNAME'
