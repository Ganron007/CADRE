# ws01 tooling inventory + AdminService reachability as svc_sccm — analyst_t1
$ErrorActionPreference = 'Continue'
Write-Output '=== 1. Tooling inventory ==='
Write-Output ("  powershell=" + $PSVersionTable.PSVersion)
foreach ($t in @('Rubeus.exe','curl.exe','python.exe','python3.exe','SharpSCCM.exe','mimikatz.exe')) {
  $found = Get-Command $t -ErrorAction SilentlyContinue
  if ($found) { Write-Output ("  FOUND: " + $t + " -> " + $found.Source) }
  else {
    # search common dirs
    $hits = Get-ChildItem 'C:\' -Recurse -Depth 3 -Filter $t -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hits) { Write-Output ("  FOUND(file): " + $t + " -> " + $hits.FullName) } else { Write-Output ("  MISSING: " + $t) }
  }
}
Write-Output '=== 2. TLS config for PS 5.1 ==='
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Output '  TLS12 set' } catch { Write-Output ('  TLS err: ' + $_.Exception.Message) }
Write-Output '=== 3. AdminService reachability + auth as svc_sccm ==='
$svcUser = 'range\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)
$u = 'https://mbr02.range.local/AdminService/v1.0/'
try {
  $r = Invoke-WebRequest -Uri $u -Credential $cred -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
  Write-Output ("  AdminService v1.0 status=" + $r.StatusCode + " len=" + $r.RawContentLength)
  if ($r.Content -match 'OData|context|SMS') { Write-Output '  OData payload confirmed' }
} catch {
  Write-Output ("  AdminService ERROR: " + $_.Exception.Message)
  if ($_.Exception.Response) { Write-Output ("  HTTP status: " + [int]$_.Exception.Response.StatusCode) }
}
Write-Output '=== 4. Device records (from site provider via svc_sccm WMI) ==='
try {
  $scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD")
  $scope.Connect()
  $q = Get-WmiObject -Namespace 'root\SMS\site_CAD' -ComputerName 'mbr02.range.local' -Credential $cred -Query "SELECT ResourceID, Name, ClientVersion FROM SMS_R_System WHERE Name LIKE 'WS01' OR Name LIKE 'MBR02'" -ErrorAction Stop
  $q | ForEach-Object { Write-Output ("  " + $_.Name + " ResourceID=" + $_.ResourceID + " ClientVer=" + $_.ClientVersion) }
} catch { Write-Output ("  WMI device query ERROR: " + $_.Exception.Message) }
Write-Output 'WS01_TOOLING_DONE'
