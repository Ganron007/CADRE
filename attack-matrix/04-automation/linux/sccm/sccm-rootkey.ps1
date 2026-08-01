# Get site trusted root key (mobileclient.tcf) + client's current root key — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== mobileclient.tcf: root key section ==='
$tcf = 'C:\Program Files\Microsoft Configuration Manager\bin\x64\mobileclient.tcf'
if (Test-Path $tcf) {
  Get-Content $tcf | Where-Object { $_ -match 'Root|Key|SIGN|Signing|Trusted' } | ForEach-Object { Write-Output ("  " + $_) }
} else { Write-Output '  (no mobileclient.tcf at bin\x64)' }

Write-Output '=== Also check mobileclient.tcf in other locations ==='
foreach ($p in @('C:\Program Files\Microsoft Configuration Manager\bin\i386\mobileclient.tcf','C:\Windows\Temp\SMSSETUP\CLIENT\mobileclient.tcf')) {
  if (Test-Path $p) { Write-Output ("  FOUND: " + $p); Get-Content $p | Where-Object { $_ -match 'Root|Key|Signing|Trusted' } | ForEach-Object { Write-Output ("    " + $_) } }
}

Write-Output '=== Client current trusted root key / security config ==='
$paths = @('HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client','HKLM:\SOFTWARE\Microsoft\CCM','HKLM:\SOFTWARE\Microsoft\SMS\Security')
foreach ($p in $paths) {
  if (Test-Path $p) {
    Write-Output ("  --- " + $p)
    Get-ItemProperty $p -ErrorAction SilentlyContinue | Format-List * | Out-String -Width 200 | ForEach-Object { $_.Split("`n") | Where-Object { $_ -match 'Root|Key|Cert|Sign|Trust' } | ForEach-Object { Write-Output ("    " + $_.Trim()) } }
  }
}
Write-Output '=== root\ccm\Policy\Machine\ActualConfig or Security store ==='
try {
  Get-WmiObject -Namespace root\ccm\Policy\Machine -Class ActualConfig -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object { Write-Output ("  " + $_.KeyName) }
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }
try {
  Get-WmiObject -Namespace root\ccm -List -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Trust|Root|Security|Cert' } | ForEach-Object { Write-Output ("  WMI CLASS: " + $_.Name) }
} catch { Write-Output ("  WMI list ERROR: " + $_.Exception.Message) }
Write-Output 'ROOTKEY_DONE'
