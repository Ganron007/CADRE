# CADRE — Attack Flow Diagram

## 5-Stage Attack Chain

```mermaid
graph TD
    subgraph Stage1[Stage 1 — Recon]
        A1[Null Session<br/>WT#028]
        A2[Password Spray<br/>WT#031]
        A3[BloodHound Enum]
    end

    subgraph Stage2[Stage 2 — Harvest Credentials]
        B1[AS-REP Roast<br/>WT#003]
        B2[AES Kerberoast<br/>WT#002]
        B3[Cross-Forest Kerberoast<br/>WT#033]
        B4[SPN Jacking<br/>WT#027]
        B5[NTLM Farming<br/>WT#009 idea]
    end

    subgraph Stage3[Stage 3 — Enumerate Attack Surface]
        C1[ACL Analysis<br/>WT#013-016]
        C2[Delegation<br/>WT#004-008]
        C3[ADCS Enum<br/>WT#050-062]
        C4[MSSQL Enum<br/>WT#040-044]
        C5[gMSA/dMSA<br/>WT#024,026]
    end

    subgraph Stage4[Stage 4 — Escalate Privilege]
        D1[Shadow Creds<br/>WT#008]
        D2[RBCD<br/>WT#007]
        D3[Constrained Del<br/>WT#005-006]
        D4[DCSync<br/>WT#009]
        D5[ADCS ESC<br/>WT#050-062]
        D6[GPO Abuse<br/>WT#023]
        D7[SCCM Escalation<br/>WT#034-039]
    end

    subgraph Stage5[Stage 5 — Lateral Movement]
        E1[Golden Ticket<br/>WT#010]
        E2[Silver Ticket<br/>WT#011]
        E3[Diamond Ticket<br/>WT#012]
        E4[MSSQL Linked<br/>Server Hop WT#040]
        E5[SCCM CMPivot<br/>WT#037]
        E6[Linux Container<br/>Escape WT#048]
    end

    A1 --> B1
    A2 --> B1
    A3 --> C1
    A3 --> C2
    A3 --> C3
    B1 --> D1
    B2 --> C5
    B3 --> C2
    B4 --> C2
    C1 --> D1
    C1 --> D2
    C2 --> D3
    C3 --> D5
    C4 --> E4
    C5 --> D4
    D1 --> D4
    D2 --> D4
    D3 --> D4
    D4 --> E1
    D4 --> E2
    D4 --> E3
    D5 --> D4
    D6 --> D4
    D7 --> E5
    E4 --> E6
    E5 --> D7
```

## Minimum Path to Domain Admin (cadre.local)

```mermaid
graph LR
    Start[AS-REP Roast WT#003] --> Crack[Crack hash → intern_blue]
    Crack --> ACL[ForceChangePassword WT#015<br/>hunter_dfir → chief_command]
    ACL --> DA[Domain Admin chief_command]
    DA --> DCSync[DCSync WT#009]
    DCSync --> Persist[Golden Ticket WT#010]
```

## Target IP Map

| Host | IP | Domain | Role |
|------|----|--------|------|
| dc01 | 192.168.77.10 | cadre.local | Root forest DC |
| dc02 | 192.168.77.11 | child.cadre.local | Child domain DC |
| dc03 | 192.168.77.12 | range.local | External forest DC |
| mbr01 | 192.168.77.22 | child.cadre.local | Member (IIS, MSSQL) |
| mbr02 | 192.168.77.23 | range.local | Member (SCCM, MSSQL, WSUS, ADCS) |
| linux01 | 192.168.77.40 | cadre.local | Linux AD member (MSSQL, NFS, Podman) |
| elk | 192.168.77.50 | — | Elastic + Fleet Server |
| vr | 192.168.77.51 | — | Velociraptor Server |
| monitor | 192.168.77.55 | — | Zeek + Suricata + Arkime |
| provisioning | 192.168.77.60 | — | Ansible provisioning |

## Trust Relationships

```mermaid
graph TD
    cadreroot[cadre.local<br/>Root Forest] --> child[child.cadre.local<br/>Child Domain]
    cadreroot <--> range[range.local<br/>External Forest]
    cadreroot --- cadrelink[Bidirectional Transit<br/>Parent-Child]
    cadreroot --- rangelink[Bidirectional<br/>Forest Trust]
```
