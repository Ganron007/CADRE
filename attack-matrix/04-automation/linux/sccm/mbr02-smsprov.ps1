Get-Content 'C:\Program Files\Microsoft Configuration Manager\Logs\SMSProv.log' -Tail 40 -ErrorAction SilentlyContinue | Where-Object { $_ -match 'Script|error|Error|fail|Fail|CreateScripts|0x' } | Select-Object -Last 25
Write-Output 'SMSProv_DONE'
