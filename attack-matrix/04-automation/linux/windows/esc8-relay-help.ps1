# Check ntlmrelayx options for custom SMB port
$ErrorActionPreference = "Continue"
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
python "$py\ntlmrelayx.py" -h 2>&1 | Select-String "smb-port|SMB PORT|interface-ip|listening port"
