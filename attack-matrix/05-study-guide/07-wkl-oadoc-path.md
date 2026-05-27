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

## Walkthrough Sequence (16 total)

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#029 | DPAPI Master Key Theft | Medium |
| 2  | WT#030 | DPAPI Credential Blob Decryption | Medium |
| 3  | WT#034 | LSA Protection Bypass | Hard |
| 4  | WT#035 | Credential Guard Bypass | Hard |
| 5  | WT#036 | Group Policy Preference (GPP) Password Extraction | Medium |
| 6  | WT#037 | SYSVOL Enumeration | Medium |
| 7  | WT#038 | GPO Abuse (Delegation) | Hard |
| 8  | WT#039 | GPO Abuse (Immediate Task) | Hard |
| 9  | WT#049 | WSUS Intrusion (Update Poisoning) | Hard |
| 10 | WT#050 | ESC1 — Misconfigured Certificate Templates | Medium |
| 11 | WT#051 | ESC2 — Any-Purpose Template | Medium |
| 12 | WT#052 | ESC3 — Enrollment Agent | Medium |
| 13 | WT#056 | ESC7 — CA Interface (NACL) Abuse | Hard |
| 14 | WT#058 | ESC9 — No Security Extension | Hard |
| 15 | WT#059 | ESC10 — Weak Certificate Mapping | Hard |
| 16 | WT#061 | ESC12 — Shell Access via CA Web Enrollment | Hard |

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
| SCCM site server (`mbr04`) with client deployment | Full SCCM attack chain practice |
| WSUS server role on `mbr05` | WSUS poisoning lab (rare in cert prep labs) |
| ADCS CA on `mbr02` | PKI infrastructure attack surface (ESC1–ESC15) |
| 26+ GPOs deployed across domains | GPO abuse and enumeration practice |
| Full 3-domain forest | Realistic enterprise scale |
| DFIR monitoring on SCCM/WSUS servers | Understand detection of enterprise attacks |
