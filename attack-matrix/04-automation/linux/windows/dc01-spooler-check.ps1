# Check dc01 spooler state + MS-RPRN RPC endpoint as chief_command (DA)
$ErrorActionPreference = "Continue"
$env:PYTHONIOENCODING = "utf-8"

Write-Output "=== dc01 spooler service via WMI as chief_command ==="
$secpwd = ConvertTo-SecureString "C0mm@nd_Ch1ef!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("cadre.local\chief_command", $secpwd)
try {
  $s = Get-WmiObject -Class Win32_Service -ComputerName dc01.cadre.local -Credential $cred -Filter "Name='Spooler'" -ErrorAction Stop
  $s | Format-List Name,State,StartMode,Status
} catch {
  Write-Output "wmi_failed: $($_.Exception.Message)"
}

Write-Output "=== dc01 spooler via sc.exe with chief_command ==="
sc.exe \\dc01.cadre.local query Spooler 2>&1 | Select-Object -First 10

Write-Output "=== check MS-RPRN endpoint via python-rpc (rpcclient-style) ==="
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
Get-ChildItem "$py\*.py" -Name | Where-Object { $_ -match "rpcclient|rpcdump" }
