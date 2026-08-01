$logdirs = @('C:\Program Files\SMS_CCM\Logs','C:\Program Files\Microsoft Configuration Manager\Logs','C:\Windows\CCM\Logs')
$hits = @()
foreach ($d in $logdirs) {
  if (Test-Path $d) {
    Get-ChildItem $d -Filter *.log -ErrorAction SilentlyContinue | ForEach-Object {
      $m = Select-String -Path $_.FullName -Pattern 'ClientOperation|CMPivot|CMPivotResult|Notification|SMS_ClientOperation|fast channel|FastChannel' -ErrorAction SilentlyContinue | Select-Object -Last 4
      foreach ($x in $m) { $hits += ("$($_.Name) :: " + $x.Line.Substring(0, [Math]::Min(300, $x.Line.Length))) }
    }
  }
}
Write-Output ("TOTAL HITS: " + @($hits).Count)
$hits | Select-Object -Last 40
Write-Output 'GREP_DONE'
