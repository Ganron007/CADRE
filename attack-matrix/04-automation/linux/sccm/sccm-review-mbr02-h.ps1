# SCCM mbr02 part H — post-reinstall diagnosis: site identity + setup logs + setup still running?
$ErrorActionPreference = 'Continue'

# 1) Site identity (registry property names have spaces)
$id = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Identification' -ErrorAction SilentlyContinue
if ($id) {
    Write-Output ("SITE_CODE=" + $id.'Site Code')
    Write-Output ("SITE_NAME=" + $id.'Site Name')
    Write-Output ("SITE_VERSION=" + $id.Version)
} else { Write-Output "ID_KEY=NONE" }

# 2) Setup still running?
$procs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'setup|ConfigMgr|smssetup' } | ForEach-Object { $_.ProcessName })
Write-Output ("SETUP_PROCS=" + ($procs -join ','))

# 3) ConfigMgrSetup.log — tail + AdminService mentions
foreach ($p in @('C:\ConfigMgrSetup.log','C:\Program Files\Microsoft Configuration Manager\Logs\ConfigMgrSetup.log','C:\Windows\Temp\ConfigMgrSetup.log')) {
    if (Test-Path $p) {
        Write-Output ("SETUPLOG_PATH=" + $p)
        $log = Get-Content $p -ErrorAction SilentlyContinue
        Write-Output ("SETUPLOG_TAIL=" + (($log | Select-Object -Last 12) -join ' | '))
        $as = @($log | Select-String -Pattern 'AdminService|admin service|Administration service' | Select-Object -Last 8)
        Write-Output ("SETUPLOG_ADMINSVC=" + (($as | ForEach-Object { $_.Line }) -join ' | '))
        break
    }
}

# 4) smsprov.log tail
$sp = 'C:\Program Files\Microsoft Configuration Manager\Logs\smsprov.log'
if (Test-Path $sp) {
    $spTail = @(Get-Content $sp -Tail 12 -ErrorAction SilentlyContinue)
    Write-Output ("SMSPROV_TAIL=" + ($spTail -join ' | '))
    $spAs = @($spTail | Select-String -Pattern 'AdminService|admin service')
    Write-Output ("SMSPROV_ADMINSVC=" + (($spAs | ForEach-Object { $_.Line }) -join ' | '))
} else { Write-Output "SMSPROV_LOG=MISSING" }

Write-Output "REVIEW_H_DONE"
