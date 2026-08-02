# Compare key tools between ADTools (CRTP) and CRTE_Tools (CRTE) + SHA256
$ErrorActionPreference = 'Continue'
$dirs = @('C:\Tools\ADTools', 'C:\Tools\CRTE_Tools\Tools')
$names = @('SharpDPAPI.exe','SafetyKatz.exe','Rubeus.exe','Loader.exe','mimikatz.exe','mimikatz_trunk\x64\mimikatz.exe','NetLoader.exe','DCOMRunAs.exe','MS-RPRN.exe','GoldenGMSA.exe','Whisker.exe','SharpGPOAbuse.exe','DefenderCheck.exe','AmsiTrigger_x64.exe','Keycred.exe','ChromElevator.exe','SharpADWS.exe','SOAPHound.exe')
foreach ($n in $names) {
  foreach ($d in $dirs) {
    $p = Join-Path $d $n
    if (Test-Path $p) {
      $f = Get-Item $p
      $h = (Get-FileHash $p -Algorithm SHA256).Hash.Substring(0,16)
      "{0,-40} {1,9}  {2}  {3}" -f $n, $f.Length, $h, $f.LastWriteTime.ToString('yyyy-MM-dd')
    } else {
      "{0,-40} {1,9}  {2}" -f $n, 'MISSING', $d
    }
  }
  Write-Output '--'
}
Write-Output 'COMPARE_DONE'
