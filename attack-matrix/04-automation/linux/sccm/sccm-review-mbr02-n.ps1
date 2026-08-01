# SCCM mbr02 part N — REAL AdminService indicators: RESTPROVIDER logs, 443 listener, WMI class
$ErrorActionPreference = 'Continue'

$p1 = 'C:\Program Files\Microsoft Configuration Manager\logs\RESTPROVIDERSetup.log'
if (Test-Path $p1) {
    Write-Output "RESTPROV_SETUP_LOG=EXISTS"
    Write-Output ("RESTPROV_SETUP_TAIL=" + ((Get-Content $p1 -Tail 30 -ErrorAction SilentlyContinue) -join ' | '))
} else { Write-Output "RESTPROV_SETUP_LOG=MISSING" }

$p2 = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $p2) {
    Write-Output "RESTPROV_LOG=EXISTS"
    Write-Output ("RESTPROV_TAIL=" + ((Get-Content $p2 -Tail 20 -ErrorAction SilentlyContinue) -join ' | '))
} else { Write-Output "RESTPROV_LOG=MISSING" }

$nl = netstat -ano | findstr ":443"
Write-Output ("NETSTAT_443=" + ($nl -join ' | '))

try { $as = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_AdminService -ErrorAction Stop); Write-Output ("AS_WMI_ROWS=" + $as.Count) } catch { Write-Output ("AS_WMI=" + $_.Exception.Message) }

Write-Output "REVIEW_N_DONE"
