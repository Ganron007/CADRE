# WT011 silver — real-service verify via smbclient.py -k (explicit silver ticket)
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'
$smb = 'C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\smbclient.py'
$env:KRB5CCNAME = "$out\wt011-silver.ccache"

Write-Output "CCACHE $(Test-Path $env:KRB5CCNAME)"

python $smb -k -no-pass 'child.cadre.local/Administrator@mbr01.child.cadre.local' -c 'ls' 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "SMB|$_" }

# If ls worked, also list C$ share root
Write-Output '--- try c$ ---'
python $smb -k -no-pass 'child.cadre.local/Administrator@mbr01.child.cadre.local' -c 'use c$; ls' 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "SMB_C|$_" }
Write-Output 'WT011_SMB3_DONE'
