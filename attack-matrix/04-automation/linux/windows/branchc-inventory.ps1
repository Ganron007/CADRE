# Branch C inventory — ws01 beachhead
$ErrorActionPreference = "SilentlyContinue"
Write-Output "=== C:\Tools listing ==="
Get-ChildItem C:\Tools -ErrorAction SilentlyContinue | Select-Object Name | Format-Table -AutoSize | Out-String -Width 200
Write-Output "=== C:\Tools\ADTools ==="
Get-ChildItem C:\Tools\ADTools -ErrorAction SilentlyContinue | Select-Object Name, Length | Format-Table -AutoSize | Out-String -Width 200
Write-Output "=== C:\Tools\cadre-attack ==="
Get-ChildItem C:\Tools\cadre-attack -Recurse -ErrorAction SilentlyContinue | Select-Object FullName | Format-Table -AutoSize | Out-String -Width 250
Write-Output "=== SharpSCCM search (C:\Tools) ==="
Get-ChildItem C:\Tools -Recurse -Filter "SharpSCCM*" -ErrorAction SilentlyContinue | Select-Object FullName | Out-String -Width 250
Write-Output "=== PXEThief search ==="
Get-ChildItem C:\Tools -Recurse -Filter "PXEThief*" -ErrorAction SilentlyContinue | Select-Object FullName | Out-String -Width 250
Write-Output "=== Reachability mbr02.range.local ==="
foreach ($port in 80,443,445,135,8530,69) {
    $r = Test-NetConnection -ComputerName "mbr02.range.local" -Port $port -WarningAction SilentlyContinue
    Write-Output ("mbr02:{0} -> {1}" -f $port, $r.TcpTestSucceeded)
}
Write-Output "=== DNS mbr02 ==="
try { Resolve-DnsName mbr02.range.local | Select-Object Name, IPAddress | Format-Table -AutoSize | Out-String -Width 200 } catch { Write-Output "DNS FAIL: $_" }
Write-Output "=== Current user context ==="
whoami
Write-Output "DONE"
