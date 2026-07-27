# Kerberos User-to-User Authentication & UnPAC-the-Hash

> **Source:** SpecterOps, "User-to-User Authentication: Down the Rabbit Hole — Part 1" by Raj Patel (2026-06-09)
> **URL:** https://specterops.io/blog/2026/06/09/user-to-user-authentication-down-the-rabbit-hole-part-1/
> **Status:** Part 1 of 2. Part 2 TBD.
> **CADRE relevance:** ADCS ESC → UnPAC-the-Hash chain. Branch B (ADCS) post-ESC credential extraction.

---

## What U2U Is

User-to-User (U2U) authentication solves the problem of authenticating to a service that has no SPN. Regular user accounts don't have SPNs, so the KDC can't find a long-term key to encrypt service tickets. U2U encrypts the service ticket using the hosting user's TGT session key instead.

**Protocol flow:**
1. Client sends `KERB-TGT-REQUEST` to target service
2. Service responds with `KERB-TGT-REPLY` containing its own TGT
3. Client sends TGS-REQ to KDC with target's TGT in `additional-tickets` field + `ENC-TKT-IN-SKEY` flag
4. KDC decrypts additional TGT with KRBTGT key, extracts session key, uses it to encrypt the U2U service ticket
5. Client decrypts U2U ticket using the session key it already has

**Key insight:** TGTs are encrypted with KRBTGT key — handing them out is safe. The session key inside is inaccessible without KRBTGT. A TGT alone is unusable without its session key.

---

## Three U2U Scenarios (from draft RFC)

### Scenario 1 — Client Already Knows (Implemented in Windows)
Client proactively requests target's TGT via `KERB-TGT-REQUEST`, then does U2U exchange. **This is the only scenario consistently observed in Windows.**

**Real-world example:** RDP with Network Level Authentication (NLA). CredSSP calls `InitializeSecurityContext` with `ISC_REQ_USE_SESSION_KEY` flag → triggers U2U exchange.

### Scenario 2 — KDC Enforces U2U (NOT Implemented in Windows)
Draft says KDC MAY return `KDC_ERR_MUST_USE_USER2USER` (0x1B). **This error does not exist in Windows `kerberos.dll`.** No per-account policy forces U2U. No `userAccountControl` flag, no Group Policy setting.

### Scenario 3 — Server Enforces U2U (Conditional)
Server returns `KRB_AP_ERR_USER_TO_USER_REQUIRED` (0x45) in response to AP-REQ. In practice, the KDC returns `KDC_ERR_S_PRINCIPAL_UNKNOWN` before a service ticket is ever issued, so the client never reaches the AP stage. Only applies when a service is hardcoded to require U2U.

---

## RDP with NLA — U2U in Practice

**Why RDP uses U2U:** CredSSP requires a fresh session key (`ISC_REQ_USE_SESSION_KEY`). U2U ensures a new, non-cached session key for credential delivery. Prevents reuse of cached session keys that an attacker could extract.

**Full exchange:**
1. RDP client sends standard TGS-REQ for `TERMSRV/hostname` → gets service ticket (but never uses it)
2. Client contacts RDP server directly → `KERB-TGT-REQUEST` inside CredSSP TLS tunnel
3. Server responds with computer account's TGT (`KERB-TGT-REPLY`)
4. Client sends TGS-REQ to KDC with server's TGT in `additional-tickets` + `ENC-TKT-IN-SKEY`
5. KDC issues U2U service ticket encrypted with session key from server's TGT
6. Client sends AP-REQ with `USE-SESSION-KEY` flag set

**Important:** The TGT exchange happens inside the CredSSP TLS tunnel — NOT visible as raw Kerberos on port 88.

**CADRE connection:** RDP is enabled on mbr01. `analyst_cloud` has RDP access. Understanding U2U in RDP context helps with detection design.

---

## UnPAC-the-Hash — Extracting NT Hash via U2U

### How It Works

When a user authenticates via PKINIT (certificate-based), the NT hash is embedded in the PAC inside the TGT. This supports legacy NTLM authentication. The hash is in `PAC_CREDENTIAL_INFO`, encrypted with the "AS reply key" (derived from Diffie-Hellman shared secret + nonces).

**Attack chain:**
1. **Get certificate** — via ADCS ESC1/ESC4, Shadow Credentials, or dumping TGT from workstation
2. **PKINIT exchange** — authenticate to KDC with certificate → get TGT + session key
3. **Derive AS reply key** — from DH shared secret + nonces (same process as Windows LSA)
4. **U2U service ticket** — request service ticket for self (own computer account SPN)
5. **Decrypt service ticket** — using TGT session key (which attacker already has)
6. **Extract NT hash** — decrypt `PAC_CREDENTIAL_INFO` inside PAC using AS reply key

### Why U2U Is Required

The PAC is inside the TGT, which is encrypted with KRBTGT key — attacker can't access it directly. The trick: request a service ticket for yourself. The KDC copies the PAC from the TGT into the new service ticket, re-signs it, and encrypts with computer account's long-term key. If you request a U2U ticket (encrypted with your own TGT session key), you can decrypt it yourself — no computer account key needed.

### CADRE Attack Chain

```
ADCS ESC1 (Branch B) → certificate → PKINIT → TGT → U2U → NT hash → Pass-the-Hash
```

**Steps in CADRE:**
1. `certipy req` — get certificate via ESC1 (analyst_t1 → Administrator template)
2. `Rubeus asktgt /certificate:<pfx> /getcredentials` — PKINIT + UnPAC-the-Hash
3. NT hash extracted → use for Pass-the-Hash or request Kerberos tickets

**Alternative with Impacket:**
```bash
# Get certificate via ESC1
certipy req -u analyst_t1@child.cadre.local -p 'T13r_An@lyst!' -ca cadre-CA -template CADRE-ESC1 -upn Administrator@cadre.local -dc-ip 192.168.77.10

# PKINIT + UnPAC-the-Hash (get NT hash from certificate)
certipy auth -pfx administrator.pfx -dc-ip 192.168.77.10
# Output: NT hash for Administrator
```

---

## Detection Signals

| Signal | Source | Notes |
|--------|--------|-------|
| PKINIT AS-REQ with certificate | WinSec 4768 (PreAuthType=16) | Certificate-based auth — unusual for interactive logon |
| TGS-REQ for own SPN (U2U) | WinSec 4769 | Self-referencing TGS request |
| `ENC-TKT-IN-SKEY` flag in TGS-REQ | Zeek kerberos.log | Additional ticket in TGS-REQ |
| NT hash extraction | WinSec 4624 (Type 3/10) | Pass-the-Hash after UnPAC |

**Key detection signal:** AS-REQ with PreAuthType=16 (PKINIT) followed by TGS-REQ for own SPN with `ENC-TKT-IN-SKEY` — this is the UnPAC-the-Hash pattern.

---

## Key Takeaways for CADRE

1. **UnPAC-the-Hash is the bridge between ADCS certificate abuse and credential theft** — certificate → NT hash → Pass-the-Hash
2. **U2U is not an attack** — it's a legitimate Kerberos feature. The attack is abusing it to extract NT hashes from PKINIT TGTs.
3. **RDP with NLA uses U2U** — understanding this helps with detection design for Phase 5 lateral movement
4. **Part 2 will cover additional U2U abuse** — watch for the follow-up article
5. **Chains naturally with ESC1-ESC4** — any ADCS certificate abuse leads to UnPAC-the-Hash → NT hash → full domain compromise

---

## Sources

- SpecterOps: https://specterops.io/blog/2026/06/09/user-to-user-authentication-down-the-rabbit-hole-part-1/
- MITRE: T1558.004 (Steal or Forge Kerberos Tickets: AS-REP Roasting — related via PAC extraction)
- MITRE: T1649 (Steal or Forge Authentication Certificates)
- Impacket: `certipy auth` handles UnPAC-the-Hash automatically
- Rubeus: `Rubeus asktgt /certificate:<pfx> /getcredentials` — extracts NT hash via UnPAC-the-Hash

---

*Part 2 pending. Last updated: 2026-06-09*
