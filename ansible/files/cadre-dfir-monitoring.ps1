# =============================================================================
# CADRE DFIR MONITORING PREP  —  Enhanced Logging Only (No Hardening)
# -----------------------------------------------------------------------------
# Purpose   : Maximum forensic visibility for CADRE attack practice / DFIR labs
# Profile   : SANS FOR508 / Hunt-Evil aligned. Sysmon is NOT in this script —
#             it is installed separately by ansible/roles/security/tasks/sysmon.yml.
# Behavior  : Pure telemetry — does NOT block, restrict, or harden anything.
#             Every attack technique will still succeed; they will simply be
#             logged in greater detail across all data sources.
# Idempotent: Yes. Safe to re-run. Designed for Ansible / WinRM embedding.
# Deploy to : All 5 Windows Server 2025 VMs (dc01, dc02, dc03, mbr01, mbr02)
# Exit code : 0 on success, non-zero == count of registry/auditpol failures.
#             Missing event channels (e.g. CA channel on a non-CA host) are
#             reported but do NOT count as failures.
# =============================================================================

#Requires -RunAsAdministrator
#Requires -Version 5

$ErrorActionPreference = 'Continue'
$script:Errors = 0

function Write-Section($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function Write-OK($t)      { Write-Host "  [+] $t" -ForegroundColor Green }
function Write-Warn($t)    { Write-Host "  [!] $t" -ForegroundColor Yellow }
function Write-Fail($t)    { Write-Host "  [-] $t" -ForegroundColor Red; $script:Errors++ }

function Set-RegDword($Path, $Name, $Value) {
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
    } catch { Write-Fail "$Path\$Name : $($_.Exception.Message)" }
}
function Set-RegString($Path, $Name, $Value) {
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType String -Force | Out-Null
    } catch { Write-Fail "$Path\$Name : $($_.Exception.Message)" }
}

# =============================================================================
# [1/7] ADVANCED AUDIT POLICY SUBCATEGORIES
# =============================================================================
Write-Section '[1/7] Advanced Audit Policy Subcategories'

$subcategories = @(
    # ----- Account Logon (Kerberos / NTLM cred validation) -----
    'Credential Validation'
    'Kerberos Authentication Service'
    'Kerberos Service Ticket Operations'
    'Other Account Logon Events'

    # ----- Logon / Logoff -----
    'Logon'
    'Logoff'
    'Special Logon'
    'Account Lockout'
    'Other Logon/Logoff Events'
    'Group Membership'                            # 4627 - token group membership at logon

    # ----- Account Management -----
    'User Account Management'
    'Computer Account Management'
    'Security Group Management'
    'Distribution Group Management'
    'Application Group Management'
    'Other Account Management Events'

    # ----- Detailed Tracking -----
    'Process Creation'
    'Process Termination'
    'DPAPI Activity'
    'RPC Events'
    'Plug and Play Events'                        # USB / removable device insertion
    'Token Right Adjusted Events'

    # ----- Directory Service -----
    'Directory Service Access'
    'Directory Service Changes'
    'Directory Service Replication'
    'Detailed Directory Service Replication'      # 4928-4931 - DCShadow visibility

    # ----- Object Access -----
    'File Share'
    'Detailed File Share'
    'File System'
    'Kernel Object'
    'Registry'
    'SAM'
    'Removable Storage'
    'Certification Services'                      # ADCS operations
    'Handle Manipulation'
    'Other Object Access Events'                  # Scheduled task / COM

    # ----- Policy Change -----
    'Audit Policy Change'
    'Authentication Policy Change'
    'Authorization Policy Change'
    'MPSSVC Rule-Level Policy Change'             # Windows Firewall rule changes
    'Filtering Platform Policy Change'
    'Other Policy Change Events'

    # ----- Privilege Use -----
    'Sensitive Privilege Use'
    'Non Sensitive Privilege Use'

    # ----- System -----
    'Security State Change'
    'Security System Extension'
    'System Integrity'
    'IPsec Driver'
    'Other System Events'
)

$applied = 0
foreach ($s in $subcategories) {
    auditpol /set /subcategory:"$s" /success:enable /failure:enable 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { $applied++ } else { Write-Warn "Not applied (OS variant?): $s" }
}
Write-OK "$applied / $($subcategories.Count) audit subcategories enabled (success+failure)."

# OPTIONAL: 'Filtering Platform Connection' (5156) gives flow-style network
# telemetry without Sysmon, but is extremely noisy (will burn 1GB Security log
# in minutes on a busy DC). Uncomment if you want it:
# auditpol /set /subcategory:'Filtering Platform Connection' /success:enable /failure:disable | Out-Null


# =============================================================================
# [2/7] PERSIST GRANULAR AUDIT POLICY
# =============================================================================
Write-Section '[2/7] Persist Granular Audit Policy'

Set-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'SCENoApplyLegacyAuditPolicy' 1
Write-OK 'SCENoApplyLegacyAuditPolicy=1 - subcategory policy will survive GPO refresh.'


# =============================================================================
# [3/7] PROCESS CREATION COMMAND LINE (Event 4688)
# =============================================================================
Write-Section '[3/7] Process Creation - Command Line Inclusion'

Set-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit' `
             'ProcessCreationIncludeCmdLine_Enabled' 1
Write-OK '4688 events will now include full command line arguments.'


# =============================================================================
# [4/7] POWERSHELL DEEP VISIBILITY
# =============================================================================
Write-Section '[4/7] PowerShell - ScriptBlock / Module / Transcription'

$psBase = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell'

# ---- ScriptBlock Logging (4104) - full deobfuscated script body ----
Set-RegDword "$psBase\ScriptBlockLogging" 'EnableScriptBlockLogging' 1
Write-OK 'ScriptBlockLogging enabled (event 4104 - full script body, post-deobfuscation).'

# ---- Module Logging (4103) - pipeline parameter/value capture ----
Set-RegDword "$psBase\ModuleLogging" 'EnableModuleLogging' 1
if (-not (Test-Path "$psBase\ModuleLogging\ModuleNames")) {
    New-Item -Path "$psBase\ModuleLogging\ModuleNames" -Force | Out-Null
}
Set-RegString "$psBase\ModuleLogging\ModuleNames" '*' '*'
Write-OK 'ModuleLogging enabled (event 4103) with ModuleNames = *  <- the bit most configs miss.'

# ---- Transcription - full session record to disk ----
$transDir = 'C:\PSTranscripts'
Set-RegDword  "$psBase\Transcription" 'EnableTranscripting'  1
Set-RegDword  "$psBase\Transcription" 'EnableInvocationHeader' 1
Set-RegString "$psBase\Transcription" 'OutputDirectory' $transDir
if (-not (Test-Path $transDir)) { New-Item -Path $transDir -ItemType Directory -Force | Out-Null }
Write-OK "Transcription enabled with InvocationHeader.  Output dir: $transDir"


# =============================================================================
# [5/7] NTLM AUDITING  (audit-only - no traffic is blocked)
# =============================================================================
Write-Section '[5/7] NTLM Auditing - Audit Only (no NTLM is restricted)'

Set-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' 'RestrictSendingNTLMTraffic' 1
Set-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' 'AuditReceivingNTLMTraffic' 2
Set-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' 'AuditNTLMInDomain' 7
Write-OK 'NTLM in/out auditing enabled (events 8001-8004 in NTLM/Operational).'
Write-Info 'NOTE: RestrictSendingNTLMTraffic=1 blocks outbound NTLM. For MDE P2 audit-only mode, set this to 0.'


# =============================================================================
# [5a/7] SERVER-ROLE AUDITING (ADCS + DNS) — only if the role is installed
# =============================================================================
Write-Section '[5a/7] Server-Role Auditing (ADCS + DNS)'

$caSvc = Get-Service -Name 'CertSvc' -ErrorAction SilentlyContinue
if ($caSvc) {
    & certutil -setreg CA\AuditFilter 255 | Out-Null
    Write-OK 'ADCS CA AuditFilter=255 enabled (EIDs 4886/4887/4899 for ESC abuse detection).'
} else {
    Write-Info 'ADCS CertSvc not installed; CA auditing skipped.'
}

$dnsSvc = Get-Service -Name 'DNS' -ErrorAction SilentlyContinue
if ($dnsSvc) {
    'y' | wevtutil sl 'Microsoft-Windows-DNS-Server/Analytical' /e:true /ms:268435456 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-OK 'DNS Server Analytical channel enabled (256 MB).'
    } else {
        Write-Warn 'DNS Server Analytical channel could not be enabled.'
    }
} else {
    Write-Info 'DNS Server not installed; DNS Server Analytical channel skipped.'
}


# =============================================================================
# [6/7] OPERATIONAL CHANNELS  -  Enable & Resize (256 MB each)
# =============================================================================
Write-Section '[6/7] Operational Channels'

$channels = @(
    # --- Lateral movement / remote access ---
    'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'      # RDP session lifecycle (21/24/25)
    'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'  # RDP auth (1149)
    'Microsoft-Windows-WinRM/Operational'                                     # PSRemoting / WinRM
    'Microsoft-Windows-PowerShell/Operational'                                # 4103 / 4104 destination
    'Microsoft-Windows-SmbClient/Security'                                    # SMB client auth events
    'Microsoft-Windows-SMBServer/Audit'                                       # SMBv1 usage, auth attempts
    'Microsoft-Windows-SMBServer/Operational'

    # --- Persistence / execution ---
    'Microsoft-Windows-TaskScheduler/Operational'                             # task create / delete / run
    'Microsoft-Windows-WMI-Activity/Operational'                              # WMI perm. event consumers, queries

    # --- Network / staging ---
    'Microsoft-Windows-DNS-Client/Operational'                                # 3008 - DNS query telemetry
    'Microsoft-Windows-Bits-Client/Operational'                               # BITS jobs (LOLBin exfil/stage)

    # --- Coercion / exploitation ---
    'Microsoft-Windows-PrintService/Operational'                              # PrintNightmare / PrinterBug
    'Microsoft-Windows-PrintService/Admin'
    'Microsoft-Windows-NTLM/Operational'                                      # 8001-8004 NTLM auditing

    # --- Code execution context ---
    'Microsoft-Windows-CodeIntegrity/Operational'                             # driver / binary integrity
    'Microsoft-Windows-AppLocker/EXE and DLL'                                 # populated if AppLocker policy exists
    'Microsoft-Windows-AppLocker/MSI and Script'
    'Microsoft-Windows-AppLocker/Packaged app-Execution'

    # --- ADCS - only present on a Certificate Authority host ---
    'Microsoft-Windows-CertificationAuthority-CertSvc/Operational'

    # --- AMSI - script content before deobfuscation, BEFORE Defender/PS sees it ---
    'Microsoft-Windows-AMSI/Operational'                                      # 1101-1102

    # --- Defender (telemetry only - does NOT change blocking behavior) ---
    'Microsoft-Windows-Windows Defender/Operational'                          # 1116/1117 detect/block events

    # --- Server 2025 additions (not present on 2022 — silently skipped) ---
    'Microsoft-Windows-Kerberos/Operational'                                  # Kerberos errors, RC4 rejections, AES enforcement failures (critical for CVE-2026-20833)
    'Microsoft-Windows-Kerberos-Key-Distribution-Center/Operational'          # KDC-side ticket issuance/rejection
    'Microsoft-Windows-LDAP-Client/Debug'                                     # LDAP signing failures (relay detection)
    'Microsoft-Windows-Security-Mitigations/UserMode'                         # Exploit protection events (ASR, DEP, ASLR)
    'Microsoft-Windows-Credential-Guard/Operational'                          # Credential Guard events (when enabled on dc03)
)

$enabled = 0; $skipped = 0
foreach ($c in $channels) {
    'y' | wevtutil sl $c /e:true /ms:268435456 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-OK "256MB : $c"
        $enabled++
    } else {
        Write-Warn "Channel not present on this host: $c"
        $skipped++
    }
}
Write-Host "  Channels enabled: $enabled  /  skipped: $skipped" -ForegroundColor Gray


# =============================================================================
# [7/7] CORE EVENT LOG RETENTION SIZES
# =============================================================================
Write-Section '[7/7] Core Log Sizes'

$logSizes = [ordered]@{
    'Security'                                                 = 1073741824   # 1 GB
    'System'                                                   = 536870912    # 512 MB
    'Application'                                              = 536870912    # 512 MB
    'Microsoft-Windows-PowerShell/Operational'                  = 536870912    # 512 MB
    'Windows PowerShell'                                       = 536870912    # 512 MB
    'Microsoft-Windows-Sysmon/Operational'                      = 1073741824   # 1 GB (Sysmon gets same as Security)
}
foreach ($k in $logSizes.Keys) {
    # Some Windows 11 builds silently fail if the log channel is actively written
    # while we resize it. Try up to 3 times with a short pause, and capture the
    # real error so operators can diagnose failures.
    $set = $false
    $lastErr = $null
    for ($i = 1; $i -le 3; $i++) {
        $err = (& wevtutil sl $k /ms:$($logSizes[$k]) 2>&1)
        if ($LASTEXITCODE -eq 0) {
            $set = $true
            break
        }
        $lastErr = $err
        Start-Sleep -Milliseconds 250
    }
    if ($set) {
        Write-OK ("{0,-55} -> {1} MB" -f $k, ($logSizes[$k] / 1MB))
    } else {
        Write-Warn "Could not resize: $k (wevtutil exit $LASTEXITCODE; $lastErr)"
    }
}


# =============================================================================
# Summary
# =============================================================================
Write-Host "`n=============================================================" -ForegroundColor Green
if ($script:Errors -eq 0) {
    Write-Host " CADRE DFIR Monitoring Prep - COMPLETE" -ForegroundColor Green
} else {
    Write-Host " CADRE DFIR Monitoring Prep - $($script:Errors) registry/policy error(s)" -ForegroundColor Yellow
}
Write-Host " Sysmon intentionally excluded. Install separately (sysmon.yml)." -ForegroundColor Gray
Write-Host " Reboot recommended for all audit changes to take full effect." -ForegroundColor Gray
Write-Host "=============================================================`n" -ForegroundColor Green

exit $script:Errors
