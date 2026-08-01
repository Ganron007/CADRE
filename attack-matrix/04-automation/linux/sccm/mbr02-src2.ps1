if (Test-Path 'C:\SCCM_Extracted') {
  Write-Output 'SCCM_Extracted EXISTS'
  Get-ChildItem 'C:\SCCM_Extracted\SMSSETUP\BIN\I386' -Filter '*.msi' -ErrorAction SilentlyContinue | Select-Object Name
  Get-ChildItem 'C:\SCCM_Extracted' -Recurse -Filter 'handler.ashx' -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 10
  Get-ChildItem 'C:\SCCM_Extracted' -Recurse -Filter '*SMS_BGB*' -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 10
} else { Write-Output 'NO SCCM_Extracted' }
