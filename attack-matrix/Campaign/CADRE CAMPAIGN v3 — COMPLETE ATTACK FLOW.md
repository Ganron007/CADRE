# CADRE CAMPAIGN v3 — COMPLETE ATTACK FLOW

> **Reference diagram** for [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) — credential chain, branch divergence/convergence, AD objectives, credential-flow summary, and branch decision matrix. Reference view only: phase narratives + live commands live in the runbooks.

```text
================================================================================
                    CADRE CAMPAIGN v3 — COMPLETE ATTACK FLOW
         Credential Chain · Branch Divergence/Convergence · AD Objectives
================================================================================

LEGEND:
  [CRED]   = Credential obtained / used in this phase
  [GAIN]   = What you earn (privilege / access / object)
  [SEED]   = Lab-deployed credential (not earned — needs spray/crack/seed)
  ──────►  = Required path (main spine)
  ─ ─ ─►   = Optional branch (parallel / alternative)


PHASE 0.5 — INITIAL ACCESS (ws01 Workstation)
═══════════════════════════════════════════════════════════════════════════════
  Source: Kali (.60) or phishing delivery
  Target: ws01 (.62) — Windows 11, MDE P2, Elastic Agent
  [CRED] None (user execution)
  [GAIN] child\analyst_t1 C2 session (local admin on ws01)
  Tools:  LNK, MSI, CHM, HTML smuggling, AutoIt3, EXE (H-01..H-06)
  Note:   Skip when running assume-breach automation (analyst_t1 pre-seeded)


PHASE 0 — RECONNAISSANCE (Zero Creds → Valid Usernames)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 or Kali
  Target: dc02 (.11) child KDC, dc01 (.10) root KDC
  [CRED] None
  [GAIN] 20 valid usernames across child + cadre domains
  Tools:  nmap krb5-enum-users, kerbrute, NetExec (pre2k, enum_av, get-desc-users)


PHASE 1 — AS-REP ROAST (First Credential)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 as child\analyst_t1
  Target: dc02 (.11) — child.cadre.local KDC
  [CRED] analyst_t1 (from Phase 0.5)
  [GAIN] intern_blue AS-REP hash → crack → 1nt3rn_Blu3!
  Tools:  Rubeus asreproast, impacket-GetNPUsers, NetExec --asreproast
  Hashcat: -m 18200 (AS-REP etype 23)


PHASE 2 — KERBEROAST via ACE#18 BRIDGE (Service Account)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 as intern_blue
  Target: dc02 (.11) — child.cadre.local KDC
  [CRED] intern_blue (from Phase 1)
  [GAIN] svc_mssql TGS → crack → s3rv1c3_MSSQL!
  Key:    ACE#18 — intern_blue has ForceChangePassword on analyst_t2
          Reset analyst_t2 password → get TGT → request SPN TGS
  Tools:  bloodyAD set password, Rubeus kerberoast, impacket-GetUserSPNs
  Hashcat: -m 13100 (TGS etype 23 RC4)
  SPNs:   svc_mssql (MSSQLSvc/mbr01.child.cadre.local:1433)
          analyst_t1 (homoglyph SPN — decoy)


PHASE 3 — EXECUTION (SQL → GodPotato → SYSTEM on mbr01)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 as analyst_t1 (or svc_mssql)
  Target: mbr01 (.22) — SQL Server 2022 Express
  [CRED] analyst_t1 (SQL auth, IMPERSONATE sa) or svc_mssql
  [GAIN] OS command execution as nt service\mssql$sqlexpress
         → SeImpersonatePrivilege → GodPotato → nt authority\system
  Tools:  impacket-mssqlclient, xp_cmdshell, GodPotato-NET4.exe
  Note:   analyst_t1 has IMPERSONATE sa (per 09-sql-wsus-verify.yml)
          svc_mssql is sysadmin but NOT the identity used for IMPERSONATE
  ───────────────────────────────────────────────────────────────────────────
  │  BRANCH D — LINUX PIVOT (diverges here, optional)                        │
  │  ─────────────────────────────────────────────────────────────────────   │
  │  Entry: MSSQL linked server from mbr01 -> linux01 (.40)                   │
  │  [CRED] analyst_t1 or svc_mssql (SQL context)                            │
  │  [GAIN] SQL exec on linux01 -> SSSD tickets -> keytab -> NFS -> Podman root  │
  │  Tools: impacket-mssqlclient OPENQUERY, podman exec, klist, mount -t nfs │
  │  Converges: May extract creds that help Phase 6 (not required)           │
  └──────────────────────────────────────────────────────────────────────────


PHASE 3.5 — CREDENTIAL THEFT + LATERAL MOVEMENT (SYSTEM on mbr01)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 → SYSTEM on mbr01 (via SQL → GodPotato channel)
  Target: mbr01 (.22)
  [CRED] analyst_t1 (to reach mbr01), then SYSTEM
  [GAIN] analyst_cloud plaintext password: Cl0ud_An@lyst!
         (from Winlogon registry auto-logon — PRIMARY method 3.5A)
         (or from LSASS dump — backup method 3.5F)
  Tools:  campaign-a-t035a-winlogon-creds.ps1, mimikatz sekurlsa::logonpasswords
  Also:   T101 — WinRS from ws01 to mbr01 as analyst_t1 (lateral movement)


PHASE 4 — DISCOVERY (BloodHound as analyst_cloud)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 → SYSTEM on mbr01 (or analyst_cloud session)
  Target: dc02 (.11) + dc01 (.10) — LDAP queries
  [CRED] analyst_cloud (from Phase 3.5A) or SYSTEM on mbr01
  [GAIN] Full BloodHound zip: sessions, ACLs, trusts, local groups, GPO, ADCS
  Tools:  SharpHound.exe -c All, bloodhound-python
  Finds:  mbr01$ TrustedForDelegation=True (→ Phase 5)
          ACE#7 hunter_dfir→chief_command (→ Branch A)
          ADCS templates CADRE-ESC1..17 (→ Branch B)
          svc_sccm SCCM Full Admin + SPN (→ Phase 8 / Branch C)
          MSSQL linked server to linux01 (→ Branch D)
  ───────────────────────────────────────────────────────────────────────────
  │  BRANCH A — ACL ABUSE (diverges here, alternative to spine P5-P7)       │
  │  ─────────────────────────────────────────────────────────────────────   │
  │  Entry: BloodHound reveals ACEs in cadre.local                           │
  │  [SEED] hunter_dfir / DF1R_Hunt3r!  ← obtained via WT031 password spray  │
  │  [SEED] analyst_dfir / An@lyst_DF1R! ← obtained via WT031 password spray │
  │  [SEED] eng_agentic / Ag3nt1c_Eng!  ← obtained via WT031 password spray  │
  │  [GAIN] cadre.local DA via ForceChangePassword (ACE#7) or GenericAll     │
  │  Key:   ACE#7 = hunter_dfir → chief_command: ForceChangePassword       │
  │         ACE#5 = analyst_dfir → OU=Command: GenericAll                  │
  │         ACE#13+14 = eng_agentic → DC=cadre: GetChanges+All (DCSync)      │
  │  Tools: bloodyAD set password, PowerView Add-DomainObjectAcl             │
  │  Converges: Skip Phase 5-6-7 entirely — go straight to Phase 8           │
  │             with chief_command (DA) or eng_agentic (DCSync rights)       │
  └──────────────────────────────────────────────────────────────────────────
  ───────────────────────────────────────────────────────────────────────────
  │  BRANCH B — ADCS (diverges here, alternative to spine P5-P7)            │
  │  ─────────────────────────────────────────────────────────────────────   │
  │  Entry: BloodHound reveals ADCS templates on dc01 (cadre.local)           │
  │  [CRED] chief_command / C0mm@nd_Ch1ef! (DA+EA from Branch A T015)          │
  │  [ALT]  Golden Ticket (administrator@cadre.local) from Phase 7             │
  │  [GAIN] Certificate as administrator → PKINIT → DA/EA without krbtgt      │
  │  Key:   ESC1 = CADRE-ESC1 template, enrollee supplies subject             │
  │         ESC3 = Enrollment Agent certificate abuse                         │
  │         ESC8 = NTLM relay to CertSrv web enrollment                       │
  │  Tools: Certify.exe, certipy req, certipy auth, ntlmrelayx.py             │
  │  Converges: Skip Phase 5-6-7 — authenticate as administrator directly   │
  │             then proceed to Phase 8 with EA-equivalent access             │
  └──────────────────────────────────────────────────────────────────────────


PHASE 5 — COERCION + DELEGATION (Capture dc02$ TGT)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 → SYSTEM on mbr01
  Target: dc02 (.11) coerced to auth to mbr01 (.22)
  [CRED] analyst_t1 (to reach mbr01), SYSTEM on mbr01
  [GAIN] dc02$ machine account TGT (captured by Rubeus monitor/dump)
  Key:    mbr01$ has TrustedForDelegation=True (unconstrained delegation)
          SpoolSample triggers dc02$ to authenticate to mbr01
  Tools:  SpoolSample.exe, Rubeus.exe monitor/dump, MS-RPRN (PrinterBug)
  Detect: Suricata SID:1000050 (MS-RPRN), Zeek dce_rpc.log
  ───────────────────────────────────────────────────────────────────────────
  │  ALTERNATIVE: RBCD (WT007) — if unconstrained delegation not available   │
  │  [CRED] svc_mssql or any cred with GenericWrite on target computer       │
  │  [GAIN] S4U2Proxy as DA on target                                        │
  │  ALTERNATIVE: Branch A (WT015/WT031) — ForceChangePassword via           │
  │  hunter_dfir or password spray to cadre.local privileged users.           │
  │  WT031 validated: chief_command / analyst_dfir / analyst_cloud.          │
  │  chief_command is DA+EA in cadre.local → fastest path to root DA.        │
  └──────────────────────────────────────────────────────────────────────────┘

PHASE 6 — DCSYNC (Child Domain Admin)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 or mbr01 (using dc02$ TGT from Phase 5)
  Target: dc02 (.11) — child.cadre.local KDC
  [CRED] dc02$ TGT (from Phase 5) OR child DA credential
  [GAIN] child krbtgt hash + all user/computer hashes
         → Domain Admin in child.cadre.local
  Tools:  mimikatz lsadump::dcsync, impacket-secretsdump -just-dc
  Detect: WinSec 4662 (DS Replication), Suricata SID:1000002 (63 fires)


PHASE 7 — GOLDEN TICKET + EXTRASIDS (Root Enterprise Admin)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 or mbr01
  Target: dc01 (.10) — cadre.local root DC
  [CRED] child krbtgt (from Phase 6) + child SID + root EA SID
  [GAIN] Enterprise Admin in cadre.local → root domain compromise
  Key:    child↔root trust has SID Filtering OFF (SIDFilteringQuarantined=$false)
          Forge TGT with child krbtgt + inject root EA SID (S-1-5-21-<root>-519)
  Tools:  Rubeus.exe golden /sids:<EA-SID> /ptt
  Alt:    Silver Ticket (WT011) — service-specific, no KDC contact
          Diamond Ticket (WT012) — modify legit TGT, stealthier


POST-DA — KDS/gMSA/dMSA + PERSISTENCE CLUSTER (WT097-109)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 or mbr01 (DA context earned in Phase 6/7)
  Target: dc01 (.10) / dc02 (.11) — KDS root key, gMSA/dMSA blobs, LAPS, DSRM
  [CRED] child DA (Phase 6) or cadre EA (Phase 7) — post-DA only
  [GAIN] KDS root key → offline gMSA/dMSA passwords (Golden gMSA/dMSA, WT098/099)
         LAPS bulk (WT100), DSRM persistence (WT101), DCShadow (WT102),
         DPAPI-NG SID-protector decryption (WT103)
  Tools:  DSIternals, GMSAPasswordReader, bloodyAD, impacket-dcshadow
  Ext:    Branch 3.5O persistence (WT104-107: DLL/COM/IFEO/LSA SSP),
          DCOMIllusionist (WT108, Phase 3 alt), ESC16 (WT109, Branch B)
  Note:   Post-DA capstone — persistence + offline-cred primitives; runs
          alongside Phase 8, does not require range.local access


PHASE 8 — CROSS-FOREST + SCCM (range.local Domain Admin)
═══════════════════════════════════════════════════════════════════════════════
  Source: ws01 or mbr01 (using cadre EA from Phase 7 / Branch A / Branch B)
  Target: dc03 (.12) — range.local root DC, mbr02 (.23) — SCCM site
  [CRED] cadre.local Enterprise Admin (Golden Ticket or cert or ACL)
  [GAIN] svc_sccm TGS → crack → s3rv1c3_SCCM!
         → read SCCM NAA file → svc_naa:N@A_s3rv1c3! (range.local DA)
         → DCSync range.local → all 3 domains compromised
  Key:    cadre↔range forest trust with SID Filter OFF
  Tools:  Rubeus kerberoast /domain:range.local, SharpSCCM, impacket-psexec
  ───────────────────────────────────────────────────────────────────────────
  │  BRANCH C — SCCM ESCALATION (second half of Phase 8, NOT optional)       │
  │  ─────────────────────────────────────────────────────────────────────   │
  │  Entry: Have svc_sccm credential (from Phase 8 cross-forest Kerberoast)  │
  │  [CRED] svc_sccm / s3rv1c3_SCCM! (from Phase 8)                          │
  │  [GAIN] svc_naa / N@A_s3rv1c3! (range.local DA) -> full forest compromise │
  │  Chain: WT034 NAA extraction -> WT035 PXE -> WT036 Client Push             │
  │         -> WT037 CMPivot -> WT038 App Deploy -> WT039 Site Takeover         │
  │  Tools: SharpSCCM.exe get naa / get pxe / client-push / cmpivot / exec   │
  │  Converges: This IS Phase 8 completion — no separate convergence         │
  └──────────────────────────────────────────────────────────────────────────


STREAMS E / F / G — STANDALONE EXERCISES (Not part of campaign narrative)
═══════════════════════════════════════════════════════════════════════════════
  E — Network Defense (14 exercises): Run on monitor VM (.55)
      DNS DGA, TXT exfil, NXDOMAIN, TLD, IP literal, TLS, SMB, HTTP, SSH
  F — Supply Chain (10 scenarios): Run on linux01 / mbr01 / npm registry
      Webhook postinstall, TruffleHog, workflow injection, package patch,
      /tmp download, npm publish worm, cloud metadata, repo weaponize,
      bundle worm, dependency confusion
  G — Pre-Auth DC Exploits (standalone CVEs): dc01, dc02, dc03
      CVE-2026-41089 Netlogon CLDAP overflow, Onelogon, Skipjack


================================================================================
                         CREDENTIAL FLOW SUMMARY TABLE
================================================================================

  #  Credential        Domain              How Obtained              Phase  Used In
  ── ───────────────── ─────────────────── ───────────────────────── ────── ───────────────
  1  analyst_t1        child.cadre.local   Phase 0.5 (assume breach)  0.5   ws01, mbr01 SQL, Branch D
  2  intern_blue       child.cadre.local   Phase 1 (AS-REP roast)     1     ACE#18 bridge
  3  svc_mssql         child.cadre.local   Phase 2 (Kerberoast)       2     SQL auth, recon
  4  analyst_cloud     cadre.local         Phase 3.5A (Winlogon reg)  3.5   BH, Branch A GPO (T023)
  5  dc02$             child.cadre.local   Phase 5 (coercion capture) 5     DCSync
  6  child krbtgt      child.cadre.local   Phase 6 (DCSync)           6     Golden Ticket
  7  cadre EA          cadre.local         Phase 7 (Golden+ExtraSids) 7     Cross-forest
  8  svc_sccm          range.local         Phase 8 (X-forest roast)   8     Branch C
  9  svc_naa           range.local         Phase 8 (SCCM NAA)         8     range DA, DCSync
  F1 chief_command     cadre.local         Branch A T015 (WT031 seed)  —     root DA+EA, Branch B entry, Branch A post-ex
  ── ───────────────── ─────────────────── ───────────────────────── ────── ───────────────
  S1 hunter_dfir       cadre.local         [SEED] WT031 password spray —     Branch A entry (ACE#7 → chief_command)
  S2 analyst_dfir      cadre.local         [SEED] WT031 password spray —     Branch A (ACE#5)
  S3 eng_agentic       cadre.local         [SEED] WT031 password spray —     Branch A (ACE#13+14 DCSync)

  IMPORTANT: analyst_t1 is a child.cadre.local user and MUST NOT be used
             for Branch A or Branch B scripts. Both branches target cadre.local.


================================================================================
                         BRANCH DECISION MATRIX
================================================================================

  Want to...                        Use Branch...   Needs Cred...       Skips...
  ─────────────────────────────────────────────────────────────────────────────
  Full learning experience          Main Spine    (earned in-chain)     Nothing
  Fastest to cadre.local DA         Branch A      hunter_dfir [SEED]    P5, P6, P7
  DA without krbtgt (cert-based)    Branch B      chief_command         P5, P6, P7
  range.local DA (required)         Branch C      svc_sccm (from P8)    Nothing
  Linux post-exploitation           Branch D      analyst_t1 (SQL)      Nothing

  NOTE: analyst_t1 is a child.cadre.local user and MUST NOT be used for
        Branch A or Branch B — both operate against cadre.local root domain.


================================================================================
                         SOLVING THE BRANCH A CREDENTIAL GAP
================================================================================

  Problem: Branch A needs cadre.local user creds (hunter_dfir, analyst_dfir,
           eng_agentic) that are NOT produced by the main spine.

  Solution paths (in order of realism):

  1. PASSWORD SPRAY (T031 — Branch G, Phase 1)
     ├─ Run kerbrute or nxc against dc01 with cadre_passwords.txt
     ├─ Add hunter_dfir, analyst_dfir, eng_agentic passwords to wordlist
     ├─ Spray AFTER Phase 0 user enum, BEFORE Phase 4 BloodHound

  2. USE ANALYST_CLOUD (earned in Phase 3.5A)
     ├─ analyst_cloud is in cadre.local and has ACE#1 (GpoEdit on Vulnerable-GPO)
     ├─ Can do GPO abuse → code exec on dc01 → extract any cred from LSASS
     ├─ Realistic: uses earned credential, teaches GPO abuse path
     └─ Limitation: Only covers ACE#1, not ACE#7/ACE#5/ACE#13+14

  3. UPDATE SEED FILE (lab-seed-creds.json)
     ├─ Add discovered credentials (chief_command, hunter_dfir, etc.)
     ├─ Mark as "seed" or "spray" source (like analyst_t1)
     ├─ Simplest for automation, but breaks "earn it" narrative
     └─ Recommended for scripted/RedStrike runs only

  4. BLOODHOUND DATA MINING
     ├─ If BH collected with high-priv user, may contain session data
     ├─ hunter_dfir may have active session on some machine
     ├─ Extract from BH zip → target that machine for cred theft
     └─ Unreliable — depends on session state at collection time

  RECOMMENDATION: Path 1 is now the canonical bridge from main spine to Branch A.
                  Path 3 is enabled for fully automated RedStrike runs.
                  Keep cadre_passwords.txt in sync with all real lab passwords.

================================================================================
```
