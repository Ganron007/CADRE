[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "C:\Tools\cadre-attack",
    [Parameter(Mandatory=$false)]
    [string]$Output = "C:\Tools\cadre-attack\potato-search.txt"
)
$ErrorActionPreference = "Stop"
$found = Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'potato' -or $_.Name -match 'dumpert' -or $_.Name -match 'katz' } | Select-Object FullName, Length
$found | Format-Table -AutoSize | Out-String | Set-Content $Output
Write-Output "POTATO_OK: wrote $($found.Count) matches to $Output"
