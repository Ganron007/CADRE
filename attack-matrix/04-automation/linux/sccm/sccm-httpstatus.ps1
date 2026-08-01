# Extract CCM_CcmHttp_Status blocks from CcmMessaging logs — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$clientLogs = 'C:\Program Files\SMS_CCM\Logs'

$files = Get-ChildItem $clientLogs -Filter 'CcmMessaging*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 3
foreach ($f in $files) {
  Write-Output ("=== " + $f.Name + " : CCM_CcmHttp_Status / HRESULT blocks ===")
  $lines = Get-Content $f.FullName
  $capture = $false
  $buf = @()
  foreach ($ln in $lines) {
    if ($ln -match 'instance of CCM_CcmHttp_Status|Raising event|HRESULT|StatusCode|HostName|DateTime =|Failed to|Delivered successfully|Location Request') {
      if ($ln -match 'instance of CCM_CcmHttp_Status') { $capture = $true; $buf = @() }
      if ($capture -or $ln -match 'Failed to|Delivered successfully|Location Request|Raising event') {
        if ($ln -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + ($ln.Trim())) }
      }
    }
    if ($ln -match '^\s*}\s*;' -and $capture) { $capture = $false; Write-Output '  ---' }
  }
}
Write-Output 'HTTPSTATUS_DONE'
