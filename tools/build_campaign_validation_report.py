#!/usr/bin/env python3
"""Build a comprehensive master campaign inventory report."""
import sys, json, pathlib
sys.stdout.reconfigure(encoding='utf-8')

# Load parsed records
parsed = json.load(open('parsed_attacks2.json', encoding='utf-8'))
parsed_by_wt = {r['wt']: r for r in parsed}

def sanitize(s):
    if not isinstance(s, str):
        return ''
    return s.replace('\n', ' ').replace('\\n', ' ').replace('\r', '').replace('|', '\\|').strip()

def rec(wt, **kwargs):
    base = parsed_by_wt.get(wt, {})
    out = {
        'id': wt,
        'name': kwargs.get('name', base.get('title', wt)),
        'machine': kwargs.get('machine', base.get('source', '')),
        'credential': kwargs.get('credential', base.get('starting_cred', '')),
        'status': kwargs.get('status', '⏳ Not tested'),
        'notes': kwargs.get('notes', base.get('note', '')),
        'retest': kwargs.get('retest', ''),
        'group': kwargs.get('group', ''),
    }
    return out

records = []

# Phase 0.5 / H (initial access, excluded)
records.append(rec('H-01', name='Malicious LNK (WT063)', machine='Kali -> ws01', credential='User execution (analyst_t1 context)', status='⏳ Not tested', group='Phase 0.5 / H', retest='Excluded from 2026-07-30 run; run from Kali with payload staged on ws01'))
records.append(rec('H-02', name='Malicious MSI (WT064)', machine='Kali -> ws01', credential='User execution', status='⏳ Not tested', group='Phase 0.5 / H', retest='Excluded'))
records.append(rec('H-03', name='Compiled HTML Help (.chm) (WT065)', machine='Kali -> ws01', credential='User execution', status='⏳ Not tested', group='Phase 0.5 / H', retest='Excluded'))
records.append(rec('H-04', name='HTML Smuggling (WT066)', machine='Kali HTTP server -> ws01', credential='User execution', status='⏳ Not tested', group='Phase 0.5 / H', retest='Excluded'))
records.append(rec('H-05', name='AutoIt3 payload (WT067)', machine='Kali -> ws01', credential='User execution', status='⏳ Not tested', group='Phase 0.5 / H', retest='Excluded'))
records.append(rec('H-06', name='Malicious EXE (WT068)', machine='Kali -> ws01', credential='User execution', status='⏳ Not tested', group='Phase 0.5 / H', retest='Excluded'))

# Phase 0 recon (pre-Phase 1)
records.append(rec('P0-Step1', name='Kerberos user enumeration', machine='Kali / provisioning', credential='None', status='✅ Verified', group='Phase 0 Recon', notes='nmap/kerbrute finds ~20 users across child + cadre domains', retest='No'))
records.append(rec('P0-Step2', name='Check DONT_REQUIRE_PREAUTH (AS-REP roastable)', machine='Kali / provisioning', credential='None', status='✅ Verified', group='Phase 0 Recon', notes='intern_blue confirmed AS-REP roastable', retest='No'))
records.append(rec('P0-Step3', name='NetExec authenticated recon (intern_blue)', machine='provisioning', credential='intern_blue / 1nt3rn_Blu3!', status='✅ Verified', group='Phase 0 Recon', notes='pre2k, enum_av, get-desc-users, asreproast, kerberoast modules', retest='No'))
records.append(rec('WT031', name='Password spray against dc01 (WT031)', machine='provisioning / Kali', credential='Candidate list (cadre_passwords.txt)', status='✅ Verified', group='Phase 0/1 Fallback', notes='Yielded chief_command / analyst_dfir / analyst_cloud / hunter_dfir in cadre.local', retest='No'))
records.append(rec('WT028', name='Null session / SAMR anonymous enumeration (WT028)', machine='Kali / provisioning', credential='None', status='❌ Rejected', group='Phase 0 Recon', notes='SAMR null bind blocked on Server 2025', retest='No'))

# Phase 1
records.append(rec('003', name='AS-REP Roast (WT003)', machine='ws01', credential=r'child\analyst_t1 / T13r_An@lyst!', status='✅ Verified', group='Phase 1', notes='Earns intern_blue / 1nt3rn_Blu3!', retest='No'))

# Phase 2
records.append(rec('002', name='Kerberoast via ACE#18 bridge (WT002)', machine='ws01', credential='intern_blue / 1nt3rn_Blu3!', status='✅ Verified', group='Phase 2', notes='ForceChangePassword analyst_t2 -> getTGT -> Kerberoast svc_mssql', retest='No'))
records.append(rec('NTLMv1', name='NTLMv1 rainbow-table downgrade', machine='Kali / provisioning', credential='Coerced NTLMv1 responder', status='⏳ Not tested', group='Phase 2 Alt', notes='SpecterOps Into The Rainbow; not in main spine', retest='Optional'))

# Phase 3
records.append(rec('041/043', name='SQL xp_cmdshell + GodPotato (WT041/WT043)', machine='ws01 -> mbr01', credential=r'child\analyst_t1 / T13r_An@lyst!', status='✅ Verified', group='Phase 3', notes=r'Returns nt service\mssql$sqlexpress then nt authority\system via GodPotato', retest='No'))
records.append(rec('042', name='CLR Assembly on mbr02 (WT042)', machine='ws01 -> mbr02', credential=r'child\analyst_t1 / T13r_An@lyst!', status='✅ Reachable', group='Phase 3', notes='CLR path reachable; actual malicious assembly not loaded in this run', retest='Yes - load and execute .NET assembly'))

# Phase 3.5
records.append(rec('101', name='WinRS lateral pivot ws01 -> mbr01 (T101)', machine='ws01', credential=r'child\analyst_t1 / T13r_An@lyst!', status='✅ Verified', group='Phase 3.5', notes='TrustedHosts + WinRM command execution works', retest='No'))
records.append(rec('3.5F', name='LSASS/SAM credential dump via mimikatz (3.5F)', machine='SYSTEM on mbr01', credential='SYSTEM', status='✅ Verified', group='Phase 3.5', notes='SAM dump works; sekurlsa::logonpasswords may fail due to token privilege', retest='Yes - capture LSASS output reliably'))
records.append(rec('3.5A', name='Winlogon plaintext credential extraction (3.5A)', machine='SYSTEM on mbr01', credential='SYSTEM', status='✅ Verified', group='Phase 3.5', notes=r'Extracts CADRE\analyst_cloud:Cl0ud_An@lyst! from registry', retest='No'))
records.append(rec('3.5G', name='DPAPI via Nemesis (3.5G)', machine='SYSTEM on mbr01', credential='SYSTEM', status='⏳ Not exercised', group='Phase 3.5', notes='Nemesis 2.2+ browser/RDP/WiFi DPAPI extraction', retest='Yes'))
records.append(rec('3.5H', name='ctfmon.exe password extraction (3.5H)', machine='SYSTEM on mbr01', credential='SYSTEM', status='⏳ Not exercised', group='Phase 3.5', notes='Typed passwords in ctfmon.exe memory', retest='Yes'))
records.append(rec('3.5I', name='Token impersonation (3.5I)', machine='mbr01', credential='SYSTEM', status='❌ Rejected', group='Phase 3.5', notes='Server 2025 session isolation; error 1346', retest='No'))
records.append(rec('3.5B', name='Scheduled Task as analyst_cloud (3.5B)', machine='mbr01', credential='analyst_cloud', status='❌ Rejected for attack chain', group='Phase 3.5', notes='Persistence only, not execution wrapper', retest='No'))
records.append(rec('3.5C', name='RDP interactive session as analyst_cloud (3.5C)', machine='ws01 -> mbr01', credential='analyst_cloud / Cl0ud_An@lyst!', status='⏳ Not exercised', group='Phase 3.5', notes='Type 10 logon + SharpHound data', retest='Yes'))
records.append(rec('3.5D', name='File detonation / payload drop (WT063-068) (3.5D)', machine='ws01 / mbr01', credential='analyst_t1 or analyst_cloud', status='⏳ Not exercised', group='Phase 3.5', notes='User-context execution', retest='Yes'))
records.append(rec('3.5J', name='WMI Event Subscriptions (3.5J)', machine='SYSTEM on mbr01', credential='SYSTEM', status='⏳ Not exercised', group='Phase 3.5', notes='Fileless persistence', retest='Yes'))
records.append(rec('3.5K', name='LSASS dump via WerFault (3.5K)', machine='SYSTEM on mbr01', credential='SYSTEM', status='⏳ Not exercised', group='Phase 3.5', notes='Microsoft-signed WerFaultSecure.exe', retest='Yes'))
records.append(rec('3.5L', name='LAPS extraction (3.5L)', machine='dc01', credential='DA', status='⏳ Not exercised', group='Phase 3.5', notes='ms-Mcs-AdmPwd read', retest='Yes'))
records.append(rec('3.5M', name='Azure AD Connect DPAPI dump (3.5M)', machine='dc01', credential='DA', status='⏳ Not exercised', group='Phase 3.5', notes='adconnectdump / MSOL credentials', retest='Yes'))
records.append(rec('3.5N', name='UnCanny LPE via InstallService (3.5N)', machine='ws01', credential='local user', status='⏳ Not exercised', group='Phase 3.5', notes='Requires Developer Mode; deferred', retest='Yes - after Developer Mode decision'))

# Phase 4
records.append(rec('004', name='BloodHound discovery (WT004)', machine='mbr01 (SYSTEM) or ws01', credential='SYSTEM on mbr01', status='✅ Verified', group='Phase 4', notes='Full AD graph collected from all 3 domains previously', retest='No'))

# Phase 5
records.append(rec('007', name='RBCD standalone (WT007)', machine='ws01', credential=r'child\analyst_t1 / T13r_An@lyst!', status='⚠️ BLOCKED', group='Phase 5', notes='PowerView LDAP query fails with operations error from ws01; script now needs redesign or proper domain context', retest='Yes - fix script and run as child user against dc02, or use DA credential'))
records.append(rec('017', name='MS-RPRN PrinterBug coercion (WT017)', machine='ws01 -> SYSTEM on mbr01', credential='SYSTEM', status='✅ Confirmed', group='Phase 5 Coercion', notes='Suricata SID:1000050 fires; dc02$ auth captured', retest='No'))
records.append(rec('018', name='MS-EFSR PetitPotam (WT018)', machine='ws01', credential='SYSTEM', status='❌ Non-functional', group='Phase 5 Coercion', notes=r'\PIPE\efsrpc blocked on Server 2025', retest='No'))
records.append(rec('019', name='MS-DFSNM DFSCoerce (WT019)', machine='ws01', credential='SYSTEM', status='❌ Non-functional', group='Phase 5 Coercion', notes='SMB-pipe DCE-RPC not detectable by Suricata 8.0.5', retest='No'))
records.append(rec('020', name='MS-FSRVP ShadowCoerce (WT020)', machine='ws01', credential='SYSTEM', status='❌ Non-functional', group='Phase 5 Coercion', notes='Service not available on Server 2025', retest='No'))
records.append(rec('021', name='NTLM relay to LDAP / ESC8 (WT021)', machine='Kali / provisioning', credential='Coerced dc02$ or other account', status='✅ Active', group='Phase 5 Coercion', notes='LDAP signing not enforced; SMB signing disabled on mbr02', retest='No'))
records.append(rec('022', name='NTLM relay to ADCS / shadow credentials (WT022)', machine='Kali / provisioning', credential='Coerced account', status='✅ Active', group='Phase 5 Coercion', notes='SMB signing disabled; relay to web enrollment', retest='No'))
records.append(rec('094', name='UnCanny Coerce (WT094)', machine='ws01', credential='local user', status='🔬 Deferred', group='Phase 5 Coercion', notes='Requires Developer Mode', retest='After Developer Mode decision'))
records.append(rec('095', name='Onelogon Zero-Channel (WT095)', machine='Kali -> DC', credential='DC machine account NTLMv2', status='🔬 Deferred', group='Phase 5 Coercion', notes='PoC expected post-WOOT 2026', retest='After PoC release'))
records.append(rec('096', name='coerce_plus consolidated check (WT096)', machine='provisioning', credential='SYSTEM context', status='⏳ Not tested', group='Phase 5 Coercion', notes='NetExec module; can be used once spooler enabled on dc02', retest='Yes'))
records.append(rec('T102', name='Unconstrained delegation capture dc02$ TGT (T102)', machine='SYSTEM on mbr01', credential='SYSTEM', status='⚠️ BLOCKED', group='Phase 5 T102', notes='SpoolSample triggered but Rubeus monitor captures 0 Kirbi from dc02$; Print Spooler on dc02 must be running/exposed', retest='Yes - fix 04-vulnerabilities.yml to enable Print Spooler on dc02'))

# Phase 6
records.append(rec('009', name='DCSync (WT009)', machine='ws01 or Kali', credential='chief_command / C0mm@nd_Ch1ef! (DA fallback)', status='✅ Verified', group='Phase 6', notes='Original as-written path (dc02$ TGT) blocked; fallback via chief_command DA works', retest='No - main path; optional: verify via dc02$ TGT once T102 fixed'))

# Phase 7
records.append(rec('010', name='Golden Ticket (WT010)', machine='ws01', credential='krbtgt hash (child.cadre.local) or chief_command fallback', status='✅ Script executes', group='Phase 7', notes='Script runs; as-written krbtgt hash path bypassed via chief_command DA', retest='Yes - verify full Golden Ticket with extracted krbtgt'))
records.append(rec('011', name='Silver Ticket (WT011)', machine='ws01', credential='Service account hash', status='✅ Script executes', group='Phase 7', notes='Script runs', retest='Yes - verify against actual service'))
records.append(rec('012', name='Diamond Ticket (WT012)', machine='ws01', credential='krbtgt hash', status='✅ Script executes', group='Phase 7', notes='Script runs', retest='Yes - verify with extracted krbtgt'))

# Phase 8
records.append(rec('033', name='Cross-forest Kerberoast (WT033)', machine='ws01', credential='root EA / chief_command', status='✅ Verified', group='Phase 8', notes='Kerberoast svc_sccm in range.local from cadre EA context', retest='No'))
records.append(rec('034', name='SCCM NAA extraction (WT034)', machine='ws01 -> mbr02', credential='svc_sccm / s3rv1c3_SCCM!', status='✅ Verified', group='Phase 8', notes=r'Reads vault\naa-rotation-notice.txt; svc_naa / N@A_s3rv1c3! confirmed DA', retest='No'))
records.append(rec('035', name='SCCM PXE Boot abuse (WT035)', machine='mbr02', credential='svc_sccm / svc_naa', status='⏳ Not exercised from ws01', group='Phase 8 / Branch C', notes='No SCCM client on ws01; must run from mbr02 or SCCM client', retest='Yes - run from mbr02/site system'))
records.append(rec('036', name='SCCM Client Push install (WT036)', machine='mbr02', credential='svc_sccm / svc_naa', status='⏳ Not exercised from ws01', group='Phase 8 / Branch C', notes='No SCCM client on ws01', retest='Yes - run from mbr02/site system'))
records.append(rec('037', name='SCCM CMPivot (WT037)', machine='mbr02', credential='svc_sccm / svc_naa', status='⏳ Not exercised from ws01', group='Phase 8 / Branch C', notes='No SCCM client on ws01', retest='Yes - run from mbr02/site system'))
records.append(rec('038', name='SCCM Application Deployment (WT038)', machine='mbr02', credential='svc_sccm / svc_naa', status='⏳ Not exercised from ws01', group='Phase 8 / Branch C', notes='No SCCM client on ws01', retest='Yes - run from mbr02/site system'))
records.append(rec('039', name='SCCM Site Takeover (WT039)', machine='mbr02', credential='svc_sccm / svc_naa', status='⏳ Not exercised from ws01', group='Phase 8 / Branch C', notes='No SCCM client on ws01; ADSI path fixed in script', retest='Yes - run from mbr02/site system'))
records.append(rec('Skipjack', name='Skipjack PAC signature corruption', machine='ws01', credential='child domain user', status='🔬 Deferred', group='Phase 8 Alt', notes='Needs custom Rubeus /skipjack_forge.py; SID filtering OFF verified', retest='After PoC'))

# Branch A
records.append(rec('015', name='ACL ForceChangePassword ACE#7 (WT015)', machine='ws01', credential='hunter_dfir / DF1R_Hunt3r!', status='✅ Verified live', group='Branch A', notes='hunter_dfir -> chief_command: ForceChangePassword; playbook fix committed', retest='No'))
records.append(rec('013', name='ACL WriteDacl self-escalate (WT013)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA)', status='📝 Script corrected, pending re-test', group='Branch A', notes='Previously used analyst_t1; now uses chief_command to grant hunter_dfir GenericAll on Command-Cadre group', retest='Yes - run after T015'))
records.append(rec('014', name='ACL GenericWrite -> Shadow Credentials (WT014)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA)', status='📝 Script corrected, pending re-test', group='Branch A', notes='Previously used analyst_t1; now uses chief_command to grant hunter_dfir GenericWrite on analyst_cloud', retest='Yes - run after T015'))
records.append(rec('016', name='ACL GenericAll on OU (WT016)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA)', status='📝 Script corrected, pending re-test', group='Branch A', notes='Previously used analyst_t1; now uses chief_command to grant hunter_dfir GenericAll on OU=Command', retest='Yes - run after T015'))
records.append(rec('008', name='Shadow Credentials on dc01$ (WT008)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA)', status='📝 Script corrected, pending re-test', group='Branch A', notes='Previously used analyst_t1; now uses chief_command to add KeyCredential to dc01$', retest='Yes - run after T015'))
records.append(rec('023', name='GPO Abuse (WT023)', machine='ws01', credential='analyst_cloud / Cl0ud_An@lyst! (ACE#1)', status='📝 Script corrected, pending re-test', group='Branch A', notes='Uses analyst_cloud extracted from mbr01 Winlogon; enumerates GPOs and links', retest='Yes'))
records.append(rec('024', name='gMSA Extraction (WT024)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA)', status='📝 Script corrected, pending re-test', group='Branch A', notes='Previously used analyst_t1; now uses chief_command with GoldenGMSA', retest='Yes - run after T015'))
records.append(rec('GPP', name='GPP Stored Password (Groups.xml)', machine='Kali / provisioning', credential='Any domain user', status='⏳ Not exercised', group='Branch A', notes='Get-GPPPassword not run', retest='Yes'))
records.append(rec('027', name='SPN Jacking CVE-2026-25177 (WT027)', machine='ws01', credential='DA or writeSPN rights', status='⏳ Not exercised', group='Branch A', notes='Abuse writeSPN/validateSPN to Kerberoast target', retest='Yes'))
records.append(rec('025', name='AdminSDHolder persistence (WT025)', machine='ws01', credential='DA', status='⏳ Not exercised', group='Branch A', notes='Modify AdminSDHolder template', retest='Yes'))

# Branch B
records.append(rec('050', name='ADCS ESC1 (WT050)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA+EA)', status='📝 Script corrected, pending re-test', group='Branch B', notes='Previously used analyst_t1 and failed DirectoryServices error; now uses chief_command@cadre.local', retest='Yes - run after T015'))
records.append(rec('051', name='ADCS ESC3 (WT051)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA+EA)', status='📝 Script corrected, pending re-test', group='Branch B', notes='Enrollment Agent abuse; now uses chief_command', retest='Yes - run after T015'))
records.append(rec('052', name='ADCS ESC8 / NTLM relay web enrollment (WT052)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA+EA)', status='📝 Script corrected, pending re-test', group='Branch B', notes='Web enrollment reachable check; now uses chief_command', retest='Yes - run after T015'))
records.append(rec('053', name='UnPAC-the-Hash (WT053)', machine='ws01', credential='chief_command / C0mm@nd_Ch1ef! (DA+EA)', status='📝 Script corrected, pending re-test', group='Branch B', notes='Certify request then Rubeus /unpac-thehash; now uses chief_command', retest='Yes - run after T015'))

# Branch D
records.append(rec('044', name='MSSQL Linked Server Recon (WT044)', machine='ws01 -> mbr01', credential=r'child\analyst_t1 / T13r_An@lyst!', status='✅ Verified', group='Branch D', notes='OPENQUERY to LINUX01.master.sys.databases returns linux01 databases', retest='No'))
records.append(rec('045', name='SSSD Ticket Extraction (WT045)', machine='linux01', credential='linux01 local access or SSH key', status='⏳ Not exercised', group='Branch D', notes='Extract Kerberos tickets from SSSD cache', retest='Yes'))
records.append(rec('046', name='MSSQL Keytab Extraction (WT046)', machine='linux01', credential='linux01 root or mssql service', status='⏳ Not exercised', group='Branch D', notes='Extract keytab used by MSSQL service', retest='Yes'))
records.append(rec('047', name='NFS Kerberos Mount (WT047)', machine='linux01', credential='Valid domain Kerberos ticket', status='⏳ Not exercised', group='Branch D', notes='Mount NFS export with sec=krb5p', retest='Yes'))
records.append(rec('048', name='Podman Container Escape (WT048)', machine='linux01', credential='Privileged container or misconfig', status='⏳ Not exercised', group='Branch D', notes='Podman privileged escape', retest='Yes'))

# Branch G
records.append(rec('CVE-2026-41089', name='Netlogon CLDAP Stack Buffer Overflow (CVE-2026-41089)', machine='Kali -> dc02', credential='None (unauthenticated UDP/389)', status='🆕 Ready, untested', group='Branch G', notes='Single UDP packet crashes LSASS; dc02 first, snapshot required', retest='Yes - snapshot dc02 and run poc.py from Kali'))

e_names = {
    1:'Kerberoast detection', 2:'DCSync detection', 3:'AS-REP roast detection', 4:'DGA detection',
    5:'DNS TXT exfil', 6:'NXDOMAIN bursts', 7:'TLD anomalies', 8:'IP literal C2',
    9:'TLS 1.0 anomalies', 10:'SNI anomalies', 11:'C2 cipher suites', 12:'SMB admin share',
    13:'SMBv1 downgrade', 14:'HTTP UA anomalies'
}
for i in range(1, 15):
    eid = f'E-{i:02d}'
    records.append(rec(eid, name=f'{eid} — {e_names[i]}', machine='monitor VM (192.168.77.55)', credential='None / SIEM analyst', status='⏳ Not exercised', group='E - Network Defense', notes='Detection rule validation; see plan1.7-defense-deepening.md', retest='Yes'))

f_names = {
    1:'npm registry poisoning', 2:'Malicious dependency install', 3:'Typosquat publish',
    4:'Compromised maintainer', 5:'Build script execution', 6:'Post-install hook',
    7:'npm token exfil', 8:'Package metadata manipulation', 9:'Cache poisoning', 10:'Tag pollution',
    11:'CI-side cache poisoning analog', 12:'Tag pollution / npm dist-tag add analog', 13:'Prepare hook / dead-man switch'
}
for i in range(1, 14):
    fid = f'F-{i:02d}'
    status = '⏳ Not exercised' if i <= 10 else '🔬 Held expansion'
    notes = 'Supply-chain simulation; see plan1.8-npm-upgrade.md' if i <= 10 else 'Plan 0.8 expansion; see CAMPAIGNS_v3.md F section + Campaign_suggestions #107'
    records.append(rec(fid, name=f'{fid} — {f_names[i]}', machine='linux01 / mbr01 / npm registry', credential='Attacker-controlled npm package or CI token', status=status, group='F - Supply Chain', notes=notes, retest='Yes'))

# Write report
report_lines = [
    '# CADRE Campaign v3 Master Validation Report — 2026-07-30',
    '',
    '> Scope: every attack, branch, and standalone exercise in Campaign v3.',
    '> Excluded from execution: Phase 0.5 / H-01..H-06 (initial access) per operator request, but they are listed.',
    '> Legend: ✅ verified / 📝 script corrected pending re-test / ⏳ not exercised / ⚠️ blocked / ❌ non-functional or rejected / 🔬 deferred.',
    '',
    '## Summary Statistics',
    '',
]

groups = {}
for r in records:
    groups.setdefault(r['group'], []).append(r)

for g, recs in groups.items():
    report_lines.append(f'- **{g}**: {len(recs)} attacks')
report_lines.append(f'- **Total attacks listed**: {len(records)}')
report_lines.append('')

for g, recs in groups.items():
    report_lines.append(f'## {g}')
    report_lines.append('')
    report_lines.append('| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |')
    report_lines.append('|------|--------|----------------|------------|--------|-------|----------------|')
    for r in recs:
        report_lines.append(f'| {sanitize(r["id"])} | {sanitize(r["name"])} | {sanitize(r["machine"])} | {sanitize(r["credential"])} | {sanitize(r["status"])} | {sanitize(r["notes"])} | {sanitize(r["retest"])} |')
    report_lines.append('')

# Add credential map and machine map
report_lines.append('## Credential Map')
report_lines.append('')
report_lines.append('| Identity | Domain | Password/Hash | Where Used | How Obtained |')
report_lines.append('|----------|--------|---------------|------------|--------------|')
report_lines.append('| `analyst_t1` | `child.cadre.local` | `T13r_An@lyst!` | ws01 beachhead, mbr01 SQL auth, mbr01 WinRM, Branch D | Assume-breach / H-01..H-06 |')
report_lines.append('| `intern_blue` | `child.cadre.local` | `1nt3rn_Blu3!` | Phase 1 recon, ACE#18 bridge | AS-REP roast (WT003) |')
report_lines.append('| `svc_mssql` | `child.cadre.local` | `s3rv1c3_MSSQL!` | Phase 2 pivot, mbr01 SQL sysadmin | Kerberoast via ACE#18 (WT002) |')
report_lines.append('| `analyst_t2` | `child.cadre.local` | reset during Phase 2 | ACE#18 bridge | `intern_blue` ForceChangePassword |')
report_lines.append('| `analyst_cloud` | `cadre.local` | `Cl0ud_An@lyst!` | mbr01 auto-logon, Branch A GPO (T023) | 3.5A Winlogon registry extraction |')
report_lines.append('| `hunter_dfir` | `cadre.local` | `DF1R_Hunt3r!` | Branch A entry (T015 ACE#7) | WT031 password spray |')
report_lines.append('| `analyst_dfir` | `cadre.local` | `An@lyst_DF1R!` | Branch A ACE#5 | WT031 password spray |')
report_lines.append('| `eng_agentic` | `cadre.local` | `Ag3nt1c_Eng!` | Branch A ACE#13+14 (DCSync) | WT031 password spray |')
report_lines.append('| `chief_command` | `cadre.local` | `C0mm@nd_Ch1ef!` | Root DA+EA, Branch A post-T015, Branch B entry | Branch A T015 / WT031 spray |')
report_lines.append('| `dc02$` | `child.cadre.local` | TGT | Phase 6 DCSync | Phase 5 coercion + Rubeus monitor (BLOCKED) |')
report_lines.append('| `child\\krbtgt` | `child.cadre.local` | hash | Phase 7 Golden Ticket | Phase 6 DCSync (fallback used) |')
report_lines.append('| `root EA` | `cadre.local` | TGT | Phase 8 cross-forest | Phase 7 Golden Ticket + ExtraSids (fallback via chief_command) |')
report_lines.append('| `svc_sccm` | `range.local` | `s3rv1c3_SCCM!` | Branch C SCCM | Phase 8 cross-forest Kerberoast (WT033) |')
report_lines.append('| `svc_naa` | `range.local` | `N@A_s3rv1c3!` | range.local DA | Branch C NAA extraction (WT034) |')
report_lines.append('')

report_lines.append('## Machine Roles')
report_lines.append('')
report_lines.append('| Machine | IP | Role | How Used in Campaign |')
report_lines.append('|---------|----|------|----------------------|')
report_lines.append('| dc01 | 192.168.77.10 | root DC `cadre.local`, CA | Branch A/B target, DCSync, Golden Ticket, ADCS |')
report_lines.append('| dc02 | 192.168.77.11 | child DC `child.cadre.local` | Phase 1/2 KDC, coercion target, Branch G target |')
report_lines.append('| dc03 | 192.168.77.12 | root DC `range.local` | Cross-forest target |')
report_lines.append('| mbr01 | 192.168.77.22 | SQL Server 2025 Express, member | Phase 3 SQL + GodPotato, Phase 3.5 credential theft |')
report_lines.append('| mbr02 | 192.168.77.23 | SCCM site server, SQL Dev | Branch C SCCM execution, Branch D linked-server source |')
report_lines.append('| linux01 | 192.168.77.40 | Ubuntu 24.04 domain-joined | Branch D pivot target |')
report_lines.append('| ws01 | 192.168.77.62 | Windows 11 beachhead | Initial beachhead, WinRM pivot to mbr01, Branch A/B execution |')
report_lines.append('| provisioning | 192.168.77.60 | Kali operator / Ansible runner | Orchestration, nxc, attack scripts |')
report_lines.append('| monitor | 192.168.77.55 | Zeek + Suricata + Elastic | E exercises detection validation (offline) |')
report_lines.append('')

report_lines.append('## Top Re-test Priorities')
report_lines.append('')
report_lines.append('1. **Enable Print Spooler on dc02** (`04-vulnerabilities.yml`) and re-run T102 coercion.')
report_lines.append('2. **Re-run all Branch A scripts after T015** using `hunter_dfir` and `chief_command`.')
report_lines.append('3. **Re-run all Branch B ADCS scripts** using `chief_command@cadre.local`.')
report_lines.append('4. **Run Branch C SCCM chain from mbr02** (WT035-039).')
report_lines.append('5. **Write and run Branch D scripts** (WT045-048).')
report_lines.append('6. **Run Branch G CVE-2026-41089** from Kali against dc02 with snapshot.')
report_lines.append('7. **Run E exercises** on monitor VM once elk/monitor are online.')
report_lines.append('8. **Run F supply-chain scenarios** on linux01/mbr01/npm registry.')
report_lines.append('')

report_lines.append('---')
report_lines.append('*Generated from CAMPAIGNS-METADATA-v2.md and 2026-07-30 validation run.*')

path = pathlib.Path('attack-matrix/Campaign/CAMPAIGNS-VALIDATION-REPORT-20260730.md')
path.write_text('\n'.join(report_lines), encoding='utf-8')
print(f'Wrote {len(records)} records to {path}')
