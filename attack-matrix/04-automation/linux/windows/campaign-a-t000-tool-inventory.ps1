[CmdletBinding()]
param()
$dirs = @("C:\Tools\ADTools", "C:\Tools\cadre-attack")
foreach ($d in $dirs) {
    Write-Output "DIR=$d"
    if (Test-Path $d) {
        Get-ChildItem $d | ForEach-Object { Write-Output ("FILE=" + $_.Name + "|" + $_.Length + "|" + $_.FullName) }
    } else {
        Write-Output "MISSING"
    }
}
