# MP install/IIS/vdir deep check — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$siteLogs = 'C:\Program Files\Microsoft Configuration Manager\Logs'

Write-Output '=== mpMSI.log tail 30 ==='
Get-Content "$siteLogs\mpMSI.log" -Tail 30 -ErrorAction SilentlyContinue | Where-Object { $_ -match 'error|Error|FAIL|failed|Return value|Installation success|vdir|Virtual|IIS|500|SMS_CCM' } | ForEach-Object { Write-Output ("  " + $_.Trim()) }

Write-Output '=== mpcontrol.log tail 25 ==='
Get-Content "$siteLogs\mpcontrol.log" -Tail 25 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }

Write-Output '=== IIS vdirs for MP ==='
Import-Module WebAdministration -ErrorAction SilentlyContinue
Get-WebApplication -Site 'Default Web Site' -ErrorAction SilentlyContinue | ForEach-Object {
  $pp = $_.PhysicalPath
  $exists = Test-Path $pp
  Write-Output ("  APP: " + $_.path + " -> " + $pp + " exists=" + $exists)
  if ($exists) {
    Get-ChildItem $pp -Filter '*.dll' -ErrorAction SilentlyContinue | Select-Object -First 5 | ForEach-Object { Write-Output ("    DLL: " + $_.Name) }
  }
}

Write-Output '=== Key MP ISAPI DLLs present? ==='
foreach ($f in @('C:\Program Files\SMS_CCM\ccmisapi.dll','C:\Program Files\SMS_CCM\ccmhttp.dll','C:\Program Files\SMS_CCM\sms_mp.dll','C:\Program Files\Microsoft Configuration Manager\bin\x64\sms_mp.dll','C:\Program Files\SMS_CCM\mp_hinv.dll')) {
  Write-Output ("  " + $f + " = " + (Test-Path $f))
}

Write-Output '=== SMS_CCM folder file count ==='
if (Test-Path 'C:\Program Files\SMS_CCM') {
  $n = @(Get-ChildItem 'C:\Program Files\SMS_CCM' -File -ErrorAction SilentlyContinue).Count
  Write-Output ("  file count=" + $n)
  Get-ChildItem 'C:\Program Files\SMS_CCM' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | ForEach-Object { Write-Output ("    " + $_.Name + " | " + $_.LastWriteTime) }
} else { Write-Output '  SMS_CCM GONE' }

Write-Output '=== MP component status in compmon summary ==='
Get-Content "$siteLogs\compsum.log" -Tail 60 -ErrorAction SilentlyContinue | Where-Object { $_ -match 'SMS_MP|MP_CONTROL|Status' } | Select-Object -Last 10 | ForEach-Object { Write-Output ("  " + $_.Trim()) }
Write-Output 'MPDEEP_DONE'
