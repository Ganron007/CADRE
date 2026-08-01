$ErrorActionPreference = 'Continue'
$dirs = @('C:\Tools\cadre-attack','C:\Tools\ADTools','C:\Tools\RedStrike')
foreach ($d in $dirs) {
  if (Test-Path $d) {
    Write-Output "=== $d ==="
    Get-ChildItem $d -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'PowerView|SharpHound|bloodyAD|BloodHound|whisker|Whisker|golden|GoldenGMSA|gmsa|ADModule|DSInternals' } | ForEach-Object { Write-Output $_.FullName }
  }
}
Write-Output "==="
# Check if PowerShell ActiveDirectory module available
try { Import-Module ActiveDirectory -ErrorAction Stop; Write-Output "ADMODULE=OK" } catch { Write-Output "ADMODULE=MISSING" }
Write-Output "WHOAMI $(whoami)"
