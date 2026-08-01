# Check ntlmrelayx verbose flag
$ErrorActionPreference = "Continue"
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
python "$py\ntlmrelayx.py" -h 2>&1 | Select-String "verbose|debug|loud|log"
