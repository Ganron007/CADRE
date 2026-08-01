# SCCM mbr02 part M — IIS features (AdminService prereqs) + setup log AdminService install action
$ErrorActionPreference = 'Continue'

# 1) IIS features via Win32_OptionalFeature (fast, unlike Get-WindowsOptionalFeature)
$feat = @(Get-CimInstance -ClassName Win32_OptionalFeature -Filter "Name LIKE 'IIS-%'" -ErrorAction SilentlyContinue | Where-Object { $_.InstallState -eq 1 } | Select-Object -ExpandProperty Name)
Write-Output ("IIS_FEATURES_ENABLED=" + ($feat -join ','))

$need = @('IIS-StaticContent','IIS-DefaultDocument','IIS-HttpErrors','IIS-ASPNET','IIS-NetFxExtensibility','IIS-ISAPIExtensions','IIS-ISAPIFilter','IIS-RequestFiltering','IIS-WebSockets','IIS-ManagementConsole','IIS-WindowsAuthentication')
foreach ($n in $need) {
    $st = Get-CimInstance -ClassName Win32_OptionalFeature -Filter "Name='$n'" -ErrorAction SilentlyContinue
    if ($st) { Write-Output ("FEAT_" + $n + "=" + $st.InstallState) } else { Write-Output ("FEAT_" + $n + "=NOTFOUND") }
}

# 2) Setup log: AdminService INSTALL action lines (not file staging)
$log = Get-Content 'C:\ConfigMgrSetup.log' -ErrorAction SilentlyContinue
$inst = @($log | Select-String -Pattern 'Installing SMS Provider|Installing AdminService|AdminService.*(Start|End|Begin|Finish)|InstallAdminService|Create.*AdminService|AdminService.*installed|AdminService.*skip|AdminService.*fail|AdminService.*error' )
Write-Output ("AS_INSTALL_LINES=" + (($inst | Select-Object -Last 12 | ForEach-Object { $_.Line }) -join ' | '))

Write-Output "REVIEW_M_DONE"
