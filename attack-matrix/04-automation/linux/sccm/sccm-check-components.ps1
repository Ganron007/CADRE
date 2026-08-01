# Check component startup inside SMS_EXECUTIVE + REST provider status
$ErrorActionPreference = 'Continue'
$exec = 'C:\Program Files\Microsoft Configuration Manager\logs\smsexec.log'
if (Test-Path $exec) {
    Write-Output ("SMSEXEC_TAIL=" + ((Get-Content $exec -Tail 20 -ErrorAction SilentlyContinue) -join ' | '))
}
$com = 'C:\Program Files\Microsoft Configuration Manager\logs\smscom.log'
if (Test-Path $com) {
    $ct = @(Get-Content $com -Tail 40 -ErrorAction SilentlyContinue)
    Write-Output ("SMSCOM_TAIL=" + ($ct -join ' | '))
    Write-Output ("SMSCOM_RESTPROV=" + (($ct | Select-String -Pattern 'REST_PROVIDER|RESTPROVIDER' | ForEach-Object { $_.Line }) -join ' | '))
} else { Write-Output "SMSCOM_LOG=MISSING" }
# is the REST provider component registered as running?
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) { Write-Output ("RESTPROV_LAST_TS=" + ((Get-Item $rp).LastWriteTime)) }
Write-Output "CHECK2_DONE"
