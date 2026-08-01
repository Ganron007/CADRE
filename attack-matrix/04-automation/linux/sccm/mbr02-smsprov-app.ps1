Write-Output '=== SMSProv.log tail (app create failure) ==='
Get-Content 'C:\Program Files\Microsoft Configuration Manager\Logs\SMSProv.log' -Tail 120 -ErrorAction SilentlyContinue | Where-Object { $_ -match 'SMS_Application|Access denied|retrieve|configuration item|CI_|HRESULT|0x8|error|Error|FAIL|Post operation|SDMPackage|GetSiteID|AccessCheck|RBA|SecuredObject' } | Select-Object -Last 40 | ForEach-Object { $_.Substring(0, [Math]::Min(260, $_.Length)) }
Write-Output 'SMSProv_DONE'
