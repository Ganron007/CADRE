# CADRE — Attack Map

> A visual mindmap of the CADRE lab's Active Directory attack surface: 3 domains, 7 hosts, ~49 users, **75 campaign attacks** + 14 E exercises + 10 F supply-chain. Updated 2026-06-03 for the single-campaign/branch structure.

---

## Overview: Domain Topology

```mermaid
graph TB
    subgraph "Forest 1 — cadre.local"
        DC01["dc01.cadre.local<br/>192.168.77.10<br/>DNS · CA · Cloud Sync"]
        CHILD["child.cadre.local<br/>192.168.77.0/24"]
        DC02["dc02.child.cadre.local<br/>192.168.77.11"]
        MBR01["mbr01.child.cadre.local<br/>192.168.77.22<br/>MSSQL · IIS · SMB:NO-SIGN<br/>Unconstrained Delegation"]
    end

    subgraph "Forest 2 — range.local"
        DC03["dc03.range.local<br/>192.168.77.12"]
        MBR02["mbr02.range.local<br/>192.168.77.23<br/>SCCM · SQL · WSUS<br/>SMB:NO-SIGN"]
    end

    subgraph "Linux"
        LX01["linux01.cadre.local<br/>192.168.77.40<br/>SSSD · NFS · Podman<br/>MSSQL-on-Linux"]
    end

    subgraph "Attack Platform"
        PROV["provisioning<br/>192.168.77.60<br/>impacket · certipy · bloodyAD<br/>coercer · kerbrute · enum4linux<br/>HTTP :8080"]
    end

    DC01 ---|"Parent-Child Trust<br/>Transitive · No SID Filter"| DC02
    DC01 -.-|"Forest Trust<br/>Bidirectional<br/>SID Filter ON"| DC03
    MBR01 -.->|"Linked Server"| LX01
```

---

## Identity Map — Users & Privileges

```mermaid
graph LR
    subgraph "cadre.local Users"
        CC["chief.command<br/>Domain Admin"]
        HD["hunter.dfir<br/>ForceChangePassword on CC"]
        LE["lead.engineering<br/>WriteDacl on Red-Cadre"]
        AC["analyst.cloud<br/>GenericWrite on Agentic-Cadre<br/>GPO Edit on Vulnerable-GPO"]
        AD["analyst.dfir<br/>GenericAll on OU=Command"]
        EC["eng.cloud<br/>ReadGMSAPassword on gmsaTools$"]
        OR["ops.redcell<br/>GenericWrite on dc01$"]
        AM["analyst.malware<br/>WriteProperty(SPN) self"]
    end

    subgraph "child.cadre.local Users"
        IB["intern.blue<br/>No PreAuth<br/>AS-REP target"]
        AT1["analyst.t1<br/>IMPERSONATE sa on MSSQL"]
        SM["svc.mssql<br/>SPN: MSSQLSvc/mbr01<br/>SQL sysadmin"]
        AT2["analyst.t2<br/>ACE#18 bridge target"]
    end

    subgraph "range.local Users"
        AO["analyst.osint<br/>GenericAll on svc.naa"]
        SVC["svc.sccm<br/>SPN: HTTP/mbr02<br/>SCCM Full Admin<br/>Constrained Delegation"]
        SNA["svc.naa<br/>Network Access Account<br/>Domain Admin"]
        AL["adversary.lead<br/>GenericWrite on dmsaPrivService$"]
    end

    subgraph "Service Accounts"
        GMSA["gmsaTools$<br/>ReadGMSAPassword by eng.cloud"]
        DMSA["dmsaPrivService$<br/>BadSuccessor target"]
        MBR01S["mbr01$<br/>Unconstrained Delegation"]
        MBR02S["mbr02$<br/>Constrained Delegation"]
    end

    HD -->|"ACE#7: ForceChangePassword"| CC
    LE -->|"ACE#3: WriteDacl"| PC
    AC -->|"ACE#4: GenericWrite"| EGA
    AD -->|"ACE#5: GenericAll on OU"| CC
    EC -->|"ACE#10: ReadGMSAPassword"| GMSA
    OR -->|"ACE#6: GenericWrite"| DC01
    AL -->|"ACE#24: GenericWrite"| DMSA
    AO -->|"ACE#23: GenericAll"| SNA
```

---

## Attack Flow — Main Spine + 4 Branches

```mermaid
graph TB
    subgraph "Main Spine — Credential Chain"
        P1["P1: AS-REP Roast (WT003)<br/>→ 1nt3rn_Blu3! (intern.blue)"]
        P2["P2: ACE#18 Bridge → Kerberoast (WT002)<br/>→ s3rv1c3_MSSQL! (svc.mssql)"]
        P3["P3: SQL xp_cmdshell (WT041)<br/>→ Code exec on mbr01"]
        P4["P4: BloodHound Discovery<br/>→ Reveals ACLs · ADCS · SCCM · Linux"]
        P5["P5: Coercion + Delegation (WT017)<br/>→ dc02$ TGT captured"]
        P6["P6: DCSync (WT009)<br/>→ child krbtgt + DA"]
        P7["P7: SID History (WT010)<br/>→ Root EA + root krbtgt"]
        P8["P8: Cross-Forest + SCCM (WT033-034)<br/>→ Range DA (all 3 domains)"]
    end

    subgraph "Branch A: ACL Abuse"
        BA1["ACE#7: ForceChangePassword (WT015)<br/>→ DA in cadre.local"]
        BA2["ACE#3/4/5: WriteDacl / GenericWrite / OU (WT013/014/016)"]
        BA3["ACE#1: GPO Abuse (WT023)<br/>→ Code exec as DA"]
        BA4["ACE#10: gMSA Extraction (WT024)"]
        BA5["ACE#6: Shadow Creds dc01$ (WT008)<br/>→ DCSync as DC"]
        BA6["SPN Jacking (WT027)<br/>→ TGS interception"]
    end

    subgraph "Branch B: ADCS"
        BB["ESC1-14 (WT050-062)<br/>→ Certificate-based DA"]
    end

    subgraph "Branch C: SCCM"
        BC1["NAA Extraction (WT034)<br/>→ Range DA (fastest)"]
        BC2["PXE / ClientPush / CMPivot / App / Site (WT035-039)"]
    end

    subgraph "Branch D: Linux Pivot"
        BD1["MSSQL Linked Server (WT044)<br/>→ Recon linux01"]
        BD2["Podman Escape (WT048)<br/>→ Root on linux01"]
        BD3["SSSD Tickets (WT045) · Keytab (WT046) · NFS (WT047)"]
    end

    P1 --> P2 --> P3 --> P4 --> P5 --> P6 --> P7 --> P8
    P4 -.-> BA1 & BA2 & BA3 & BA4 & BA5 & BA6 & BB
    P8 -.-> BC1 & BC2
    P3 -.-> BD1 --> BD2 --> BD3
```

**Main chain:** `1nt3rn_Blu3!` → `s3rv1c3_MSSQL!` → dc02$ TGT → child krbtgt → root EA → `s3rv1c3_SCCM!` → `N@A_s3rv1c3!`

**Branches diverge from Phase 4 (BH discovery)** and converge back at various points. All optional — each teaches a distinct technique class.

---

## Machine Configuration Map

```mermaid
graph TB
    subgraph "dc01 — cadre.local CA + DNS"
        DC01_S["Services"]
        DC01_CA["ADCS Enterprise CA<br/>cadre-CA"]
        DC01_D["DNS for cadre.local"]
        DC01_V["Vulnerabilities"]
        DC01_V1["LDAP Signing: NOT Required"]
        DC01_V2["WDigest: ON"]
        DC01_V3["LSA PPL: OFF"]
        DC01_V4["CredGuard: OFF"]
        DC01_V5["RestrictedAdmin: 0"]
        DC01_S --> DC01_CA
        DC01_S --> DC01_D
        DC01_V --> DC01_V1
        DC01_V --> DC01_V2
        DC01_V --> DC01_V3
        DC01_V --> DC01_V4
        DC01_V --> DC01_V5
    end

    subgraph "dc02 — child.cadre.local"
        DC02_S["Services"]
        DC02_S1["Print Spooler: ON"]
        DC02_S2["WebClient: ON"]
        DC02_S3["DFS Namespace: ON"]
        DC02_V["Vulnerabilities"]
        DC02_V1["RestrictAnonymous: 0"]
        DC02_V2["RestrictAnonymousSAM: 1 ❌"]
        DC02_V3["DONT_REQUIRE_PREAUTH: intern_blue"]
        DC02_V4["ACE#18: ForceChangePassword"]
        DC02_S --> DC02_S1
        DC02_S --> DC02_S2
        DC02_S --> DC02_S3
        DC02_V --> DC02_V1
        DC02_V --> DC02_V2
        DC02_V --> DC02_V3
        DC02_V --> DC02_V4
    end

    subgraph "dc03 — range.local"
        DC03_S["Services"]
        DC03_S1["Print Spooler: ON"]
        DC03_S2["AES-only Kerberos"]
        DC03_D["DNS for range.local"]
        DC03_V["Vulnerabilities"]
        DC03_V1["Weak Cert Mapping"]
        DC03_V2["dMSA Enabled"]
        DC03_S --> DC03_S1
        DC03_S --> DC03_S2
        DC03_S --> DC03_D
        DC03_V --> DC03_V1
        DC03_V --> DC03_V2
    end

    subgraph "mbr01 — SQL + Web"
        MBR01_S["Services"]
        MBR01_S1["MSSQL: xp_cmdshell ON"]
        MBR01_S2["IIS: Default Web Site"]
        MBR01_S3["Linked: → mbr02, linux01"]
        MBR01_S4["Unconstrained Delegation: ON"]
        MBR01_V["Vulnerabilities"]
        MBR01_V1["SMB Signing: OFF"]
        MBR01_V2["Shares: public, restricted"]
        MBR01_S --> MBR01_S1
        MBR01_S --> MBR01_S2
        MBR01_S --> MBR01_S3
        MBR01_S --> MBR01_S4
        MBR01_V --> MBR01_V1
        MBR01_V --> MBR01_V2
    end

    subgraph "mbr02 — SCCM"
        MBR02_S["Services"]
        MBR02_S1["SCCM Site: CAD"]
        MBR02_S2["MSSQL: CLR ON"]
        MBR02_S3["WSUS: ON"]
        MBR02_S4["Constrained Delegation"]
        MBR02_V["Vulnerabilities"]
        MBR02_V1["SMB Signing: OFF"]
        MBR02_V2["NAA: svc.naa (DA)"]
        MBR02_V3["PXE: No Password"]
        MBR02_S --> MBR02_S1
        MBR02_S --> MBR02_S2
        MBR02_S --> MBR02_S3
        MBR02_S --> MBR02_S4
        MBR02_V --> MBR02_V1
        MBR02_V --> MBR02_V2
        MBR02_V --> MBR02_V3
    end

    subgraph "linux01 — Linux Pivot"
        LX01_S["Services"]
        LX01_S1["MSSQL-on-Linux: ON"]
        LX01_S2["NFSv4: krb5p export"]
        LX01_S3["Podman: --privileged"]
        LX01_S4["SSSD: AD Joined"]
        LX01_V["Vulnerabilities"]
        LX01_V1["Keytab: /var/opt/mssql/secrets/"]
        LX01_V2["SSSD Cache: readable"]
        LX01_S --> LX01_S1
        LX01_S --> LX01_S2
        LX01_S --> LX01_S3
        LX01_S --> LX01_S4
        LX01_V --> LX01_V1
        LX01_V --> LX01_V2
    end
```

---

## Technique Reference — WT# Index by Machine

```mermaid
mindmap
  root((CADRE Lab<br/>99 Attacks))
    ::id root
    dc01.cadre.local
      ::id dc01
      WT008 Shadow Credentials
      WT009 DCSync
      WT010 Golden Ticket
      WT012 Diamond Ticket
      WT013 WriteDacl
      WT014 GenericWrite
      WT015 ForceChangePassword
      WT016 GenericAll OU
      WT017 PrinterBug
      WT021 NTLM Relay LDAP
      WT023 GPO Abuse
      WT024 gMSA Extract
      WT025 AdminSDHolder
      WT027 SPN Jacking
      WT050-062 ADCS ESC1-14
      WT082 LSASS Dump
      WT088 Scheduled Task
      WT089 Registry Run Key
      WT090 Host Recon
    dc02.child.cadre.local
      ::id dc02
      WT003 AS-REP Roast
      ~~WT028 Null Session~~
      ~~WT031 Password Spray~~
    dc03.range.local
      ::id dc03
      WT002 AES Kerberoast
      WT005 Constrained Deleg PT
      WT006 Constrained Deleg noPT
      WT026 dMSA BadSuccessor
      WT033 Cross-Forest Kerberoast
      WT049 VSC Enrollment
    mbr01.child.cadre.local
      ::id mbr01
      WT004 Unconstrained Deleg
      WT007 RBCD
      WT041 xp_cmdshell
      WT042 MSSQL CLR
      WT043 MSSQL Impersonation
      WT044 MSSQL Link Recon
      WT063 LNK Initial Access
      WT064 MSI Installer
      WT065 CHM Execution
      WT066 HTML Smuggling
      WT067 AutoIt3
      WT068 Malicious EXE
      WT083 Ingress Tool Transfer
      WT084 WMI Lateral
      WT085 WinRM Lateral
      WT086 RDP Lateral
      WT087 Pass-the-Hash
      WT091 Data Staging
      WT092 Screen Capture
    mbr02.range.local
      ::id mbr02
      WT022 NTLM Relay SMB
      WT030 WSUS Abuse
      WT034 SCCM NAA Extract
      WT035 SCCM PXE Boot
      WT036 SCCM Client Push
      WT037 SCCM CMPivot
      WT038 SCCM App Deploy
      WT039 SCCM Site Takeover
      ~~WT018 PetitPotam~~
      ~~WT019 DFSCoerce~~
      ~~WT020 ShadowCoerce~~
    linux01.cadre.local
      ::id linux01
      WT045 SSSD Ticket
      WT046 Keytab Abuse
      WT047 NFS Mount
      WT048 Podman Escape
      WT069 DNS DGA
      WT070 DNS TXT Burst
      WT071 DNS NXDOMAIN
      WT072 DNS TLD
      WT073 DNS IP Literal
      WT074 TLS 1.0
      WT076 HTTP Suspicious UA
      WT077 HTTP Exploit Path
      WT078 HTTP Content-Type
      WT079 SSH Brute Force
      WT080 Long Conn Beacon
      WT081 Outbound Anomaly
    provisioning
      ::id prov
      Attack Platform
      impacket · certipy · bloodyAD
      coercer · kerbrute
      HTTP :8080
```

---

## Trust & Delegation Map

```mermaid
graph LR
    subgraph "Trust Relationships"
        CADRE["cadre.local<br/>S-1-5-21-XXXX"]
        CHILD_D["child.cadre.local<br/>S-1-5-21-YYYY"]
        RANGE["range.local<br/>S-1-5-21-ZZZZ"]
    end

    subgraph "Delegation Configs"
        MBR01_D["mbr01$<br/>Unconstrained<br/>TrustedForDelegation=TRUE"]
        MBR02_D1["mbr02$<br/>Constrained+PT<br/>→ cifs/dc03, ldap/dc03"]
        SVC_D["svc.sccm<br/>Constrained noPT<br/>→ HTTP/mbr02"]
    end

    CADRE -->|"Parent-Child<br/>Transitive · No SID Filter"| CHILD_D
    CADRE -.->|"Forest<br/>Bidirectional<br/>SID Filter ON| RANGE
    MBR01_D -.->|"Captures TGT from"| CHILD_D
    MBR02_D1 -.->|"S4U2Proxy →"| RANGE
```

---

## Coverage Summary

| Section | Phase / Branch | WT# Range | Count |
|:--------|:---------------|:---------:|:-----:|
| Main Spine | P1: Initial Access | 003 | 1 |
| | P2: Credential Harvesting | 002 | 1 |
| | P3: Execution (primary + H alternate) | 041-043, 063-068 | 9 |
| | P4: Discovery | BH + 044 | 2 |
| | P5: Lateral + Coercion | 004-007, 017, 021-022 | 7 |
| | P6: DCSync | 009 | 1 |
| | P7: Forest Trust | 010-012 | 3 |
| | P8: Cross-Forest + SCCM | 033-039, 030, 049 | 10 |
| | **G — Post-Exploit** (blended inline) | 082-092 | 11 |
| Branch A | ACL Abuse | 013-016, 023-025, 027, 008 | 10 |
| Branch B | ADCS | 050-062 | 14 |
| Branch C | SCCM | 034-039, 030, 049 | 8 |
| Branch D | Linux Pivot | 044-048 | 5 |
| | **Total campaign** | **75** | **75** |
| E | Network Defense Exercises | 069-081, 093 | 14 |
| F | Supply-Chain Scenarios | F-01 to F-10 | 10 |
| | **Total lab** | **99** | **99** |

**Removed / Non-functional:** WT028 ❌ (null session), WT031 ⏳ (pending relocation), WT018/019/020 ❌ (Server 2025 coercion).
