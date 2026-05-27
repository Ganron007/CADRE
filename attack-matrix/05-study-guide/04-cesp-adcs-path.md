# CESP-ADCS — Certified Enterprise Security Professional — ADCS (Altered Security)

## Target Audience

Security professionals specializing in Active Directory Certificate Services attacks. Requires strong foundation in on-prem AD compromise (CRTP-level).

## Exam Format

| Detail | Value |
|--------|-------|
| Duration | 24 hours practical |
| Objective | Compromise PKI infrastructure, escalate to domain admin |
| Passing | Report documenting full ADCS attack chain |
| Retake | 1 free retake included |

## Focus Areas

- ESC1 — ESC15 attack techniques
- CA exploitation and theft
- Certificate theft and abuse
- NTLM relay to ADCS endpoints
- Schema and policy abuse

## Prerequisite Knowledge

- AD fundamentals (domains, users, groups, ACLs)
- Kerberos PKINIT authentication flow
- Public Key Infrastructure concepts (CA, templates, certificates)
- CRTP-level AD compromise skills
- Familiarity with `certipy`, `Certify`, `PKINITtools`

## Walkthrough Sequence (14 total)

| #  | WT ID   | Title | Difficulty |
|----|---------|-------|------------|
| 1  | WT#050  | ESC1 — Misconfigured CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT | Easy |
| 2  | WT#051  | ESC2 — Any-Purpose Template (SAN abuse) | Easy |
| 3  | WT#052  | ESC3 — Enrollment Agent (OLA/OEA) | Medium |
| 4  | WT#053  | ESC4 — ACL-Based Template Modification | Medium |
| 5  | WT#054  | ESC5 — PKI-Related AD Object ACL Abuse | Medium |
| 6  | WT#055  | ESC6 — EDITF_ATTRIBUTESUBJECTALTNAME2 on CA | Medium |
| 7  | WT#056  | ESC7 — CA Interface (NACL) Abuse | Medium |
| 8  | WT#057  | ESC8 — NTLM Relay to CA (HTTP) | Medium |
| 9  | WT#058  | ESC9 — No Security Extension (NSE) | Hard |
| 10 | WT#059  | ESC10 — Weak Certificate Mapping (SAN) | Hard |
| 11 | WT#060  | ESC11 — ICERTPASS (NTLM Relay via RPC) | Hard |
| 12 | WT#061  | ESC12 — Shell Access via CA Web Enrollment | Hard |
| 13 | WT#062  | ESC13 — CA Policy Module Abuse | Hard |
| 14 | WT#063  | ESC14 — CA Property Abuse | Hard |

## Estimated Time

| Phase | Duration |
|-------|----------|
| Walkthroughs (14 WTs, once CA active) | 10–15 hours |
| ADCS-specific tool mastery (certipy, Certify) | 5–8 hours |
| Practice chains combining ESC techniques | 5–10 hours |
| **Total** | **1–2 weeks once CA is operational** |

## Coverage: Currently ~15% ⚠️

> **Important:** The ADCS Certificate Authority service on `mbr02` is currently **stopped** and must be manually started before CESP-ADCS walkthroughs will function. Templates are deployed and verified; only ESC10 (weak certificate mapping) works in the current state.

Technically working today: **ESC10** (WT#059).  
Remaining ESC attacks (ESC1–ESC9, ESC11–ESC15): require CA service running on `mbr02`.

### To Enable Full ADCS Lab

1. RDP or WinRM to `mbr02`
2. Open Services console (`services.msc`)
3. Start `Active Directory Certificate Services` service
4. Verify with `certutil -ping` on the CA

## CADRE-Specific Advantages for CESP-ADCS

| Feature | Benefit |
|---------|---------|
| 15+ certificate templates deployed | Covers ESC1–ESC15 attack surface |
| CA accessible via HTTP + RPC | Both ESC8 and ESC11 relay paths available |
| Integration with multi-domain forest | Cross-domain PKI attacks (ESC13-style) |
| BloodHound CE + certipy pre-compatible | Rapid ACE-to-cert path analysis |
| DFIR monitoring on CA | Understand detection signatures for PKI abuse |
