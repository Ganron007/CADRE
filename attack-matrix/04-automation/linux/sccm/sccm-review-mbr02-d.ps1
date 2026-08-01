# SCCM mbr02 review PART D — AdminService prerequisites: IIS sites/bindings/SSL certs + svc_sccm logon rights
$ErrorActionPreference = 'Continue'

# 1) IIS sites + bindings (AdminService needs HTTPS/443)
$sites = & "$env:windir\system32\inetsrv\appcmd.exe" list sites 2>$null
Write-Output ("IIS_SITES=" + (($sites | Out-String) -replace "`r`n",' | '))
$binds = & "$env:windir\system32\inetsrv\appcmd.exe" list bindings 2>$null
Write-Output ("IIS_BINDINGS=" + (($binds | Out-String) -replace "`r`n",' | '))
$ssl = & "$env:windir\system32\inetsrv\appcmd.exe" list sslbindings 2>$null
Write-Output ("SSL_BINDINGS=" + (($ssl | Out-String) -replace "`r`n",' | '))

# 2) Certificates available for mbr02.range.local / range.local (HTTPS binding)
$certs = Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Where-Object { $_.HasPrivateKey -and ($_.DnsNameList -match 'mbr02' -or $_.Subject -match 'mbr02') } | ForEach-Object { ($_.Subject + '|' + $_.Thumbprint + '|' + $_.NotAfter.ToString('yyyy-MM-dd')) }
Write-Output ("MBR02_CERTS=" + ($certs -join ';'))
$certs2 = Get-ChildItem Cert:\LocalMachine\My -ErrorAction SilentlyContinue | Where-Object { $_.HasPrivateKey -and ($_.DnsNameList -match 'range\.local' -or $_.Subject -match 'RANGE') } | ForEach-Object { ($_.Subject + '|' + $_.Thumbprint + '|' + $_.NotAfter.ToString('yyyy-MM-dd')) }
Write-Output ("RANGE_CERTS=" + ($certs2 -join ';'))

# 3) svc_sccm logon-as-service right (app pool identity requirement)
$sid = ([System.Security.Principal.NTAccount]"RANGE\svc_sccm").Translate([System.Security.Principal.SecurityIdentifier]).Value
Write-Output ("SVC_SCCM_SID=" + $sid)
$cfg = 'C:\Windows\Temp\cadre-secpol.cfg'
& secedit /export /areas USER_RIGHTS /cfg $cfg | Out-Null
if (Test-Path $cfg) {
    $sec = Get-Content $cfg -Raw
    $line = (($sec -split "`r?`n") | Where-Object { $_ -match '^SeServiceLogonRight' }) -join ''
    Write-Output ("HAS_SERVICE_LOGON=" + ($line -match [regex]::Escape($sid)))
    Write-Output ("SERVICE_LOGON_ENTRIES=" + (($line -replace 'SeServiceLogonRight\s*=\s*','') -replace ',',','))
    Remove-Item $cfg -Force -ErrorAction SilentlyContinue
} else { Write-Output "SECPOL=EXPORT_FAIL" }

# 4) SMS Provider role entry (does it carry an AdminService flag?)
try {
    $provrole = @(Get-CimInstance -Namespace 'root\SMS\site_CAD' -ClassName SMS_SCI_SysResUse -Filter "RoleName='SMS Provider'" -ErrorAction Stop)
    Write-Output ("PROV_ROLE_COUNT=" + $provrole.Count)
    foreach ($p in $provrole) { Write-Output ("PROV_ROLE=" + $p.SiteSystem + '|' + $p.RoleName + '|' + $p.NALPath) }
} catch { Write-Output ("PROV_ROLE_ERR=" + $_.Exception.Message) }

# 5) quick re-confirm: AdminService still absent?
$apps = & "$env:windir\system32\inetsrv\appcmd.exe" list apps 2>$null
Write-Output ("AS_STILL_ABSENT=" + (-not ($apps -match 'AdminService')))
Write-Output "REVIEW_D_DONE"
