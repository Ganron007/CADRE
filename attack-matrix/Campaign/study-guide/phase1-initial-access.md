# Phase 1 — Initial Access (AS-REP Roasting)

> **Campaign position:** First credential in the chain. Zero credentials → low-priv domain user.
> **Attack:** WT003 — AS-REP Roasting against `intern_blue` in child.cadre.local.
> **Earns:** `1nt3rn_Blu3!` — low-privilege domain user credential.

---

## WT003 — AS-REP Roasting

### What It Does

AS-REP Roasting exploits user accounts that have `DONT_REQUIRE_PREAUTH` set in their `userAccountControl`. Normally, Kerberos requires the client to encrypt a timestamp with their password hash as part of the AS-REQ (pre-authentication). When pre-auth is disabled, the KDC responds with an AS-REP encrypted with the user's RC4-derived key — without ever requiring the password.

The attacker captures this AS-REP and cracks it offline. The cracking is fast because RC4-HMAC (etype 23) uses a single MD4 hash derivation, not the iterative key derivation that AES uses.

**Why this works in CADRE:** `05-ad-attack-surface.yml` explicitly sets `DoesNotRequirePreAuth $true` on `intern_blue`. This is a misconfiguration — in production, pre-auth should be enabled on all accounts. The lab disables it to demonstrate the attack.

**Protocol flow:**
1. Attacker sends AS-REQ for `intern_blue@CHILD.CADRE.LOCAL` with no PA-DATA (no pre-auth)
2. KDC checks `intern_blue`'s `userAccountControl` — finds `UF_DONT_REQUIRE_PREAUTH` (0x400000)
3. KDC responds with AS-REP containing the TGT encrypted with `intern_blue`'s RC4 key
4. Attacker extracts the encrypted portion and cracks it offline with hashcat mode 18200

**What makes this different from Kerberoasting:**
- AS-REP targets users with pre-auth disabled (any user can request)
- Kerberoast targets service accounts with SPNs (requires a valid TGT first)
- AS-REP doesn't need any credentials — it's a zero-knowledge attack
- Kerberoast needs at least one valid credential to start

### Step-by-Step

```bash
# 1. Create user list (from Kerberos enumeration in Phase 0)
echo intern_blue > /tmp/users.txt

# 2. Request AS-REP without pre-auth
impacket-GetNPUsers child.cadre.local/ -dc-ip 192.168.77.11 -no-pass -usersfile /tmp/users.txt

# 3. Output: $krb5asrep$23$intern_blue@CHILD.CADRE.LOCAL:579...
#    The $23 = etype 23 = RC4-HMAC

# 4. Crack with hashcat (mode 18200 for AS-REP)
hashcat -m 18200 asrep.hash cadre_passwords.txt

# 5. Result: 1nt3rn_Blu3!
```

**Expected output from GetNPUsers:**
```
$krb5asrep$23$intern_blue@CHILD.CADRE.LOCAL:579e17b8...<long hex>...
```

**Expected output from hashcat:**
```
$krb5asrep$23$intern_blue@CHILD.CADRE.LOCAL:579e17b8...:1nt3rn_Blu3!
```

### Detection

**Windows Security (on dc02):**

| Event | Field | Value | Why |
|-------|-------|-------|-----|
| 4768 | TargetUserName | intern_blue | AS-REQ for this user |
| 4768 | TicketEncryptionType | 0x17 (23) | RC4-HMAC — unusual if AES-capable |
| 4768 | PreAuthType | 0 | **No pre-auth** — this is the signal |
| 4768 | IpAddress | 192.168.77.60 | Source: Kali |

**Key detection signal:** Event 4768 with `PreAuthType = 0`. Normal Kerberos authentication always has `PreAuthType = 2` (PA-ENC-TIMESTAMP). `PreAuthType = 0` means no pre-auth was required — either the account has `DONT_REQUIRE_PREAUTH` set, or an attacker is exploiting it.

**Zeek:**
```
kerberos.log:
  request_type: AS
  client: intern_blue/CHILD.CADRE.LOCAL
  service: krbgt/CHILD.CADRE.LOCAL
  success: true
  cipher: rc4-hmac
```

**Suricata:**
- ET:2000002 — `ET TROJAN Kerberos AS-REP Without Pre-Auth (AS-REP Roast)` — fires on AS-REP with no pre-auth indicator

**Detection challenge:** A single AS-REP roast event looks like normal Kerberos authentication. The distinguishing factor is `PreAuthType = 0` — this should be rare in a properly configured environment. Correlation: if the same source IP requests AS-REPs for multiple users, that's enumeration + roasting.

### Real-World Usage

- **APT groups:** AS-REP roasting is standard initial access in AD environments. Used by APT29, APT41, and ransomware operators.
- **Red team:** First step after discovering domain users — test for pre-auth disabled accounts.
- **Detection priority:** High — any `PreAuthType = 0` event should generate an alert in production environments.
- **Mitigation:** Enable pre-auth on all accounts. Set `DONT_REQ_PREAUTH` to false. Audit accounts with `userAccountControl & 0x400000`.

### Sources

- MITRE: T1558.004 (Steal or Forge Kerberos Tickets: AS-REP Roasting)
- SpecterOps: https://www.specterops.io/blog/kerberos-user-enumeration
- Impacket: https://github.com/fortra/impacket — `GetNPUsers.py`
- Hashcat: https://hashcat.net/wiki/ — mode 18200
- Harmj0y: https://blog.harmj0y.net/kerberoasting/as-rep-roasting/
- Playbook: `05-ad-attack-surface.yml` lines 859-866 (sets DONT_REQUIRE_PREAUTH on intern_blue)
