# CARTE — Certified Azure Red Team Expert (Altered Security)

## Target Audience

Red teamers specializing in hybrid Azure AD / on-prem AD attacks. Requires CRTP or CRTE-level on-prem skills as foundation.

## Exam Format

| Detail | Value |
|--------|-------|
| Duration | 48 hours practical |
| Objective | Compromise hybrid Azure AD–on-premises environment |
| Passing | Report demonstrating full cloud-to-on-prem and on-prem-to-cloud chains |
| Retake | 1 free retake included |

## Focus Areas

- Azure AD Connect (AAD Connect) exploitation
- Password Hash Sync (PHS) abuse
- Pass-Through Authentication (PTA) abuse
- Federation trust attacks (AD FS)
- Cloud-to-on-prem lateral movement
- Seamless SSO abuse
- Hybrid identity synchronization exploitation

## Prerequisite Knowledge

- CRTP-level on-prem AD compromise
- Azure AD basics (tenants, users, groups, roles)
- Cloud identity federation concepts
- Microsoft Entra ID (formerly Azure AD) administration fundamentals
- Understanding of directory synchronization (AAD Connect, Azure AD Cloud Sync)

## Walkthrough Sequence (8 total — currently deferred)

> **Note:** Cloud-specific walkthroughs (C07–C09, H01–H04) are identified and specified but not yet implemented. The foundational on-prem infrastructure is in place.

| #  | WT ID  | Title | Status |
|----|--------|-------|--------|
| 1  | C07    | Azure AD Cloud Sync — On-Prem to Cloud Lateral Movement | Deferred |
| 2  | C08    | Azure AD Cloud Sync — Configuration Tampering | Deferred |
| 3  | C09    | Azure AD Cloud Sync — Credential Sync Exploitation | Deferred |
| 4  | H01    | Hybrid — PHS (Password Hash Sync) Abuse | Deferred |
| 5  | H02    | Hybrid — PTA (Pass-Through Authentication) Abuse | Deferred |
| 6  | H03    | Hybrid — Seamless SSO Exploitation | Deferred |
| 7  | H04    | Hybrid — Azure AD Connect Credential Theft | Deferred |
| 8  | TBD    | Federation Trust Abuse (AD FS compromise) | Planned |

## Estimated Time

| Phase | Duration |
|-------|----------|
| On-prem prerequisite refresher (CRTP-level) | 10–15 hours |
| CARTE-specific walkthroughs (once implemented) | 15–20 hours |
| Hybrid chain practice / exam simulation | 10–15 hours |
| **Total (when complete)** | **3–5 weeks at ~2h/day** |

## Coverage: ~30% (Foundational Only)

CADRE currently covers ~30% of CARTE objectives — mostly the on-prem prerequisite knowledge and infrastructure readiness.

### What's Ready Today
- `cadre.local` root domain fully compromised — all CRTP techniques work
- Azure AD Cloud Sync agent **installed and running** on `dc01`
- Cloud Sync agent connects to Azure AD tenant (enables future hybrid scenarios)
- All on-prem attack paths required as prerequisites for hybrid chains

### What's Deferred
- Cloud-side walkthroughs (C07–C09) — require Azure AD tenant interaction specification
- Hybrid chains (H01–H04) — require coordination between cloud and on-prem components
- Federation attacks — require AD FS server deployment (future plan)

## Infrastructure Status

| Component | Status | Location |
|-----------|--------|----------|
| Azure AD Cloud Sync agent | ✅ Running | `dc01` |
| On-prem domain (`cadre.local`) | ✅ Fully operational | All DCs |
| Azure AD tenant | ⏳ Requires configuration | External |
| AD FS server | ❌ Not deployed | Future plan |
| PTA agent | ❌ Not deployed | Future plan |

## CADRE-Specific Advantages for CARTE

| Feature | Benefit |
|---------|---------|
| Cloud Sync agent already running on `dc01` | Ready for C07–C09 walkthroughs immediately when written |
| Full 3-domain on-prem forest | Realistic hybrid environment scale |
| DFIR monitoring captures sync activity | Understand detection of cloud sync abuse |
| On-prem → cloud attack paths specified | Clear implementation roadmap for deferred content |
| Uses same Azure AD Connect light agent | Matches real-world enterprise hybrid deployments |
