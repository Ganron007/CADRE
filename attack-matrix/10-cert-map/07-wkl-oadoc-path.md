# WKL-OADOC — Offensive AD Operations Certification (WhiteKnight Labs)

## Target Audience

Senior penetration testers and red teamers pursuing WhiteKnight Labs' OADOC certification. Requires expert-level AD knowledge and enterprise environment experience.

## Exam Format

| Detail | Value |
|--------|-------|
| Duration | Multi-day practical (check WKL for current format) |
| Objective | Full enterprise AD compromise including SCCM, WSUS, ADCS |
| Focus | Real-world enterprise tooling abuse |
| Environment | Large multi-server AD environment |

## Focus Areas

- SCCM (Configuration Manager) exploitation
- WSUS abuse and update poisoning
- ADCS certificate services attacks
- Advanced Windows attacks (DPAPI, LSA protection bypass, Credential Guard bypass)
- PKI infrastructure abuse
- Enterprise post-exploitation persistence

## Prerequisite Knowledge

- Expert-level on-prem AD compromise
- CRTP + CRTE level skills
- Enterprise systems management concepts (SCCM, WSUS, Group Policy)
- ADCS / PKI fundamentals
- Windows internals (DPAPI, LSA, Schannel)

## Walkthrough Sequence (14 total)

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#023 | GPO Abuse (Vulnerable-GPO) | Medium |
| 2  | WT#025 | AdminSDHolder Persistence | Medium |
| 3  | WT#024 | gMSA Password Extraction | Medium |
| 4  | WT#027 | SPN Jacking (CVE-2026-25177) | Hard |
| 5  | WT#008 | Shadow Credentials (dc01$) | Hard |
| 6  | WT#029 | CertPotato (DCOM → ADCS) | Hard |
| 7  | WT#030 | WSUS Abuse (Update Poisoning) | Hard |
| 8  | WT#034 | SCCM NAA Extraction | Medium |
| 9  | WT#050 | ADCS ESC1 — Misconfigured Template | Medium |
| 10 | WT#057 | ADCS ESC8 — NTLM Relay to CA | Hard |
| 11 | WT#059 | ADCS ESC10 — Weak Certificate Mapping | Hard |
| 12 | WT#061 | ADCS ESC13 — Issuance Policy → Group Mapping | Hard |
| 13 | WT#062 | ADCS ESC14 — Explicit Certificate Mapping | Hard |
| 14 | WT#058 | ADCS ESC9 — No Security Extension | Hard |

## Estimated Time

| Phase | Duration |
|-------|----------|
| DPAPI and Windows internals (WT#029–035) | 10–12 hours |
| GPO and SYSVOL abuse (WT#036–039) | 8–10 hours |
| WSUS exploitation (WT#049) | 3–5 hours |
| ADCS attacks (WT#050–061) | 12–15 hours |
| Practice / chain building | 10–15 hours |
| **Total** | **3–5 weeks** |

## Coverage: ~60%

CADRE covers a significant portion of OADOC techniques, with noted limitations:

### Working
- SCCM infrastructure deployed (client push, NAA, policy, application deployment)
- WSUS server accessible (update poisoning path possible)
- GPO abuse paths configured
- DPAPI credential theft scenarios
- ADCS templates deployed and verified
- LSA protection bypass primitives

### Not Working / Partial
- Some ADCS attacks require CA service to be running (see CESP-ADCS path notes)
- Advanced SCCM features (secondary sites, distribution point abuse) not fully deployed
- Cross-forest SCCM scenarios not available
- Some Credential Guard bypass variants may require additional configuration

## CADRE-Specific Advantages for WKL-OADOC

| Feature | Benefit |
|---------|---------|
| SCCM site server (`mbr02.range.local`) with client deployment | Full SCCM attack chain practice |
| WSUS server role on `mbr02.range.local` | WSUS poisoning lab (rare in cert prep labs) |
| ADCS CA on `dc01.cadre.local` | PKI infrastructure attack surface (ESC1–ESC14) |
| 20+ ACEs deployed across domains | ACE abuse and enumeration practice |
| Full 3-domain forest | Realistic enterprise scale |
| DFIR monitoring (Zeek + Suricata on monitor VM) | Understand detection of enterprise attacks |
