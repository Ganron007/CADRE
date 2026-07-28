[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "192.168.77.22"
)
$ErrorActionPreference = "Stop"
whoami /priv
whoami
