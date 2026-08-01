$ErrorActionPreference = "SilentlyContinue"
$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)
$ns = "root\SMS\site_CAD"

Write-Output "=== Software Distribution PropLists ==="
$sd = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_SCI_ClientComp -Filter "ClientComponentName = 'Software Distribution'" -ErrorAction SilentlyContinue
foreach ($x in $sd) {
    foreach ($pl in $x.PropLists) {
        Write-Output ("  {0} = {1}" -f $pl.PropertyListName, ($pl.Values -join " | "))
    }
}

Write-Output "=== SMS_SCI_Component for client push / NAA (site component) ==="
$comp = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_SCI_Component -Filter "ComponentName = 'SMS_SITE_COMPONENT_MANAGER'" -ErrorAction SilentlyContinue
foreach ($x in $comp) {
    Write-Output ("  COMP: {0} | {1}" -f $x.ComponentName, $x.ItemName)
    foreach ($pl in $x.PropLists) {
        Write-Output ("    {0} = {1}" -f $pl.PropertyListName, ($pl.Values -join " | "))
    }
}

Write-Output "=== AdminService probe (/AdminService/wmi/) ==="
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
try {
    $classes = Invoke-RestMethod -Uri "https://mbr02.range.local/AdminService/wmi/" -Credential $cred -Method Get -ErrorAction Stop
    Write-Output "ADMINSERVICE_OK classes=$($classes.Count)"
    $classes | Select-Object -First 80 | ForEach-Object { Write-Output "  $_" }
} catch {
    Write-Output "ADMINSERVICE_FAIL: $($_.Exception.Message)"
}
Write-Output "DONE"
