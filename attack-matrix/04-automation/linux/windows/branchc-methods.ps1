$ErrorActionPreference = "SilentlyContinue"
$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)
$ns = "root\SMS\site_CAD"

Write-Output "=== AdminService curl status ==="
& curl.exe -k -s -o NUL -w "AS_HTTPS:%{http_code}\n" --ntlm -u "range\svc_sccm:s3rv1c3_SCCM!" --max-time 20 "https://mbr02.range.local/AdminService/wmi/" 2>&1 | Out-String
& curl.exe -k -s -o NUL -w "AS_ROOT:%{http_code}\n" --ntlm -u "range\svc_sccm:s3rv1c3_SCCM!" --max-time 20 "https://mbr02.range.local/AdminService/" 2>&1 | Out-String

Write-Output "=== SMS_Scripts methods ==="
$sc = [wmiclass]"\mbr02.range.local\root\SMS\site_CAD:SMS_Scripts"
try { ($sc.Methods | ForEach-Object { $_.Name }) -join ", " | Out-String } catch { Write-Output "ERR: $_" }

Write-Output "=== SMS_Application methods ==="
$app = [wmiclass]"\mbr02.range.local\root\SMS\site_CAD:SMS_Application"
try { ($app.Methods | ForEach-Object { $_.Name }) -join ", " | Out-String } catch { Write-Output "ERR: $_" }

Write-Output "=== SMS_Collection methods ==="
$col = [wmiclass]"\mbr02.range.local\root\SMS\site_CAD:SMS_Collection"
try { ($col.Methods | ForEach-Object { $_.Name }) -join ", " | Out-String } catch { Write-Output "ERR: $_" }

Write-Output "=== SMS_ApplicationAssignment methods ==="
$aa = [wmiclass]"\mbr02.range.local\root\SMS\site_CAD:SMS_ApplicationAssignment"
try { ($aa.Methods | ForEach-Object { $_.Name }) -join ", " | Out-String } catch { Write-Output "ERR: $_" }

Write-Output "DONE"
