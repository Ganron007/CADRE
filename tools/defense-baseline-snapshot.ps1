  # === 1. Advanced Audit Policy — all 49 subcategories ===
  auditpol /get /category:*

  # Persistence guard (the one most people forget — without this, GPO overwrites your audit policy on next refresh)
  Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' SCENoApplyLegacyAuditPolicy

  # 4688 command-line capture (separate setting from audit policy)
  Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit' ProcessCreationIncludeCmdLine_Enabled

  # === 2. PowerShell Logging — three separate modes ===
  # ScriptBlock (4104)
  Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' EnableScriptBlockLogging
  Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' EnableScriptBlockInvocationLogging
  # Module (4103) — including the wildcard most configs miss
  Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging' EnableModuleLogging
  Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' '*'
  # Transcription (full session record)
  Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' EnableTranscripting
  Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' EnableInvocationHeader
  Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' OutputDirectory

  # === 3. NTLM Auditing — three registry keys, often half-applied ===
  Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' RestrictSendingNTLMTraffic
  Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' AuditReceivingNTLMTraffic
  Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' AuditNTLMInDomain

  # === 4. Sysmon — service, config, and channel state ===
  Get-Service Sysmon64                            # Should be Running
  sc.exe qc Sysmon64                              # Start mode = auto
  Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv\Parameters' ConfigVersion 2>$null
  # Confirm config file location (sysmon stores it in registry-ish ways depending on installer)
  Get-ChildItem 'C:\Tools\Sysmon\' -ErrorAction SilentlyContinue
  Get-Content 'C:\Tools\Sysmon\sysmonconfig.xml' -TotalCount 5 -ErrorAction SilentlyContinue

  # === 5. Event Log Sizes — easy to forget after Sysmon install ===
  wevtutil gl Security              | Select-String maxSize
  wevtutil gl System                | Select-String maxSize
  wevtutil gl Application           | Select-String maxSize
  wevtutil gl "Microsoft-Windows-Sysmon/Operational"            | Select-String maxSize
  wevtutil gl "Microsoft-Windows-PowerShell/Operational"        | Select-String maxSize
  wevtutil gl "Windows PowerShell"                              | Select-String maxSize
  wevtutil gl "Microsoft-Windows-NTLM/Operational"              | Select-String maxSize

  # === 6. Operational Channels — 26+ enabled? ===
  # These are channels disabled by default that you need ON for forensics
  $channels = @(
    'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational',
    'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational',
    'Microsoft-Windows-WinRM/Operational',
    'Microsoft-Windows-PowerShell/Operational',
    'Microsoft-Windows-SmbClient/Security',
    'Microsoft-Windows-SMBServer/Audit',
    'Microsoft-Windows-SMBServer/Operational',
    'Microsoft-Windows-TaskScheduler/Operational',
    'Microsoft-Windows-WMI-Activity/Operational',
    'Microsoft-Windows-DNS-Client/Operational',
    'Microsoft-Windows-Bits-Client/Operational',
    'Microsoft-Windows-PrintService/Operational',
    'Microsoft-Windows-PrintService/Admin',
    'Microsoft-Windows-NTLM/Operational',
    'Microsoft-Windows-CodeIntegrity/Operational',
    'Microsoft-Windows-AppLocker/EXE and DLL',
    'Microsoft-Windows-AppLocker/MSI and Script',
    'Microsoft-Windows-AppLocker/Packaged app-Execution',
    'Microsoft-Windows-CertificationAuthority-CertSvc/Operational',
    'Microsoft-Windows-AMSI/Operational',
    'Microsoft-Windows-Windows Defender/Operational',
    # Server 2025-only:
    'Microsoft-Windows-Kerberos/Operational',
    'Microsoft-Windows-Kerberos-Key-Distribution-Center/Operational',
    'Microsoft-Windows-LDAP-Client/Debug',
    'Microsoft-Windows-Security-Mitigations/UserMode',
    'Microsoft-Windows-Credential-Guard/Operational'
  )
  foreach ($c in $channels) {
    $log = wevtutil gl $c 2>$null
    if ($LASTEXITCODE -eq 0) {
      "$c : ENABLED=$($log | Select-String -Pattern '^enabled' | %{$_.Line.Trim()}) MAXSIZE=$($log | Select-String -Pattern 'maxSize' | %{$_.Line.Trim()})"
    } else {
      "$c : NOT PRESENT ON THIS HOST"
    }
  }

  # === 7. AMSI integration check — does Defender actually scan? ===
  Get-MpComputerStatus | Select AMServiceEnabled, AntispywareEnabled, BehaviorMonitorEnabled, RealTimeProtectionEnabled, IoavProtectionEnabled

  # === 8. Defender exclusion list — anything excluded skews telemetry ===
  Get-MpPreference | Select ExclusionPath, ExclusionExtension, ExclusionProcess

  # === 9. Elastic Agent (if Stage B done) — agent installed and reporting ===
  Get-Service "Elastic Agent" | Select Name, Status, StartType
  & "C:\Program Files\Elastic\Agent\elastic-agent.exe" status 2>$null

  # === 10. Velociraptor client (if Stage D done) ===
  Get-Service Velociraptor | Select Name, Status, StartType

  # === 11. WEC subscription state (Windows Event Collector — only if you're using it) ===
  wecutil es 2>$null

  # === 12. Group Policy state — confirm no policy is reverting your settings ===
  gpresult /h C:\Temp\gpresult.html
  # Open the HTML and search for "audit" — any GPO overriding your settings shows here