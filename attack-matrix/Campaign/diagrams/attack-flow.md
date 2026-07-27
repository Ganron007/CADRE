# CADRE — Attack Flow Diagram

## Main Spine + 4 Branches

```mermaid
graph TD
    subgraph CredChain["Main Spine — Credential Chain"]
        C1["Phase 1: AS-REP Roast<br/>WT003 → intern.blue<br/>1nt3rn_Blu3!"]
        C2["Phase 2: Kerberoast<br/>WT002 → svc.mssql<br/>s3rv1c3_MSSQL!"]
        C3["Phase 3: SQL xp_cmdshell<br/>WT041 → mbr01 SYSTEM"]
        C4["Phase 4: BloodHound Discovery<br/>→ Reveals ACLs · ADCS · SCCM · Linux"]
        C5["Phase 5: Coercion<br/>WT017 → dc02$ TGT"]
        C6["Phase 6: DCSync<br/>WT009 → child krbtgt"]
        C7["Phase 7: SID History<br/>WT010 → root EA"]
        C8["Phase 8: Cross-Forest<br/>WT033-034 → range.local DA"]
    end

    subgraph PostDA["Post-DA Operations"]
        P1["LSASS Dump<br/>WT082"]
        P2["Alternative Lateral<br/>WT084-087"]
        P3["Persistence<br/>WT088-089"]
        P4["Collection<br/>WT091-092"]
    end

    subgraph AltEntry["Alternate Entry"]
        H["H Attacks<br/>WT063-068 → mbr01"]
        H2["LSASS Dump → analyst.cloud<br/>Cl0ud_An@lyst!"]
    end

    subgraph Branches["Branches (Optional)"]
        BA["Branch A: ACL Abuse<br/>ACE#7/3/4/5/1/6/10"]
        BB["Branch B: ADCS<br/>ESC1-14 Certificate DA"]
        BC["Branch C: SCCM<br/>NAE/PXE/CliPush/CMPivot/App"]
        BD["Branch D: Linux Pivot<br/>044-048 → domain creds"]
    end

    C1 --> C2 --> C3 --> C4 --> C5 --> C6 --> C7 --> C8
    C8 --> PostDA
    C4 -.-> BA & BB
    C3 -.-> BD
    C8 -.-> BC
    H --> H2 -.->|"alternate entry"| C5
```

**Credential chain:** `1nt3rn_Blu3!` → `s3rv1c3_MSSQL!` → dc02$ TGT → child krbtgt → root EA → `s3rv1c3_SCCM!` → `N@A_s3rv1c3!`

**Status:** 75 campaign attacks (8 phases + 4 branches) + 14 E exercises + 10 F supply-chain = 99 total. WT028 ❌, WT031 ⏳, WT018-020 ❌.

## Full Campaign

See [`../CAMPAIGNS.md`](../CAMPAIGNS.md) for the complete campaign with identity-driven credential flow, detection references, and DFIR Report real-world case studies.
