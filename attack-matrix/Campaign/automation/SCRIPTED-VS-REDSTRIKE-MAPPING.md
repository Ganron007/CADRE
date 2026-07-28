# Campaign Execution Matrix — Scripted vs RedStrike

**Path:** `docs/internal/plan1.1-campaign-automation/SCRIPTED-VS-REDSTRIKE-MAPPING.md`  
**Last updated:** 2026-07-28  
**Scope:** Every node in `attack-matrix/Campaign/automation/campaign-graph.yaml` v6.  
**Legend:**
- **Scripted** = a `.sh` harness exists in `attack-matrix/04-automation/linux/` and can be run standalone.
- **RedStrike** = `campaign-graph.yaml` has an `intent:` (typed builder) and/or the node is routable through `redstrike-campaign`.
- **Validated** = executed live with `--execute` during the P1.0 full campaign run and returned `[OK]`.

---

## Legend / status marks

| Mark | Meaning |
|------|---------|
| ✅ | Validated live RC=0 |
| ⚠️ | Script exists but live-run returned `[FAIL]` or needs a fix |
| 📦 | Script exists, not yet run live (dry-run only) |
| 📝 | Stub / placeholder only |
| ❌ | Not implemented / blocked by design |

---

## Spine — Phases 0–8

| ID | Phase | Title | Beachhead | Script path | RedStrike intent | Status | Notes |
|----|-------|-------|-----------|-------------|------------------|--------|-------|
| T028 | 0 | Null session enum | linux60 | `campaign-a/T028-nullsession.sh` | — | ✅ | Expected blocked on Server 2025; script returns OK |
| H-ASSUME | 0.5 | Assume breach as analyst_t1 | ws01 | — | — | 📝 | Stub — manual beachhead; no automation |
| T003 | 1 | AS-REP Roast | ws01 | `campaign-a/T003-asrep-ws01.sh` | `rubeus.asreproast` | ✅ | Uses `intern_blue` hash |
| T002 | 2 | Kerberoast (svc_mssql) | ws01 | `campaign-a/T002-kerb-ws01.sh` | `rubeus.kerberoast` | ✅ | Direct Rubeus from ws01 |
| T041 | 3 | SQL auth → xp_cmdshell | ws01 | `campaign-a/T041-xpcmd-ws01.sh` + `windows/campaign-a-t041-xpcmd.ps1` | `sql.xp_cmdshell` | ✅ | IMPERSONATE sa on mbr01 |
| T043 | 3 | IMPERSONATE sa → GodPotato | ws01 | `campaign-a/T043-impersonate-ws01.sh` + `windows/campaign-a-t043-impersonate.ps1` | — | ✅ | SYSTEM on ws01 via GodPotato |
| T035-CREDS | 3.5 | Post-SYSTEM credential dump | ws01 | — | — | 📝 | Stub — need mimikatz sekurlsa/lsassy |
| T004-BH | 4 | BloodHound collection (analyst context) | ws01 | — | — | 📝 | Stub — need SharpHound.exe from ws01 |
| T017 | 5 | PrinterBug / MS-RPRN coercion | ws01 | `attacks/WT017-printerbug-spoolsample.sh` | — | ✅ | MS-RPRN.exe on ws01 via WinRM |
| T009 | 6 | DCSync | ws01 | `campaign-a/T009-dcsync-ws01.sh` | — | ✅ | Extracts krbtgt from cadre.local |
| T010 | 7 | Golden Ticket | ws01 | `campaign-a/T010-golden-ws01.sh` | — | ✅ | Forged with extracted krbtgt AES256 |
| T011 | 7 | Silver Ticket | ws01 | `campaign-a/T011-silver-ws01.sh` | — | ✅ | CIFS/MBR01 service ticket |
| T012 | 7 | Diamond Ticket | ws01 | `campaign-a/T012-diamond-ws01.sh` + `windows/campaign-a-t012-diamond.ps1` | — | ✅ | Golden-equivalent for chief_command |
| T033 | 8 | Cross-forest Kerberoast | ws01 | `campaign-a/T033-xforest-ws01.sh` | — | ✅ | range.local SPN roast |
| T042 | 8 | MSSQL CLR assembly | ws01 | `campaign-a/T042-clr-ws01.sh` | — | ✅ | mbr02 CLR re-verify |

---

## Branch A — ACL Abuse

| ID | Phase | Title | Beachhead | Script path | RedStrike intent | Status | Notes |
|----|-------|-------|-----------|-------------|------------------|--------|-------|
| T015 | 4 | ACL ForceChangePassword | ws01 | `campaign-a/T015-acl-forcechangepassword-ws01.sh` | `bloodyad.set_password` | ✅ | Resets analyst_t2 password |
| T013 | 4 | ACL WriteDacl | ws01 | `campaign-a/T013-acl-writedacl-ws01.sh` | — | ✅ | PowerView Add-DomainObjectAcl |
| T014 | 4 | ACL GenericWrite | ws01 | `campaign-a/T014-acl-genericwrite-ws01.sh` | — | ✅ | PowerView on analyst_t2 |
| T016 | 4 | ACL GenericAll on OU | ws01 | `campaign-a/T016-acl-genericall-ou-ws01.sh` | — | ✅ | Operations OU |
| T023 | 5 | GPO abuse | ws01 | `campaign-a/T023-gpo-abuse-ws01.sh` | — | ✅ | Read-only GPO enumeration |
| T008 | 5 | Shadow credentials | ws01 | `campaign-a/T008-shadow-credentials-ws01.sh` | — | ✅ | Whisker.exe + Rubeus |
| T024 | 5 | gMSA extraction | ws01 | `campaign-a/T024-gmsa-extraction-ws01.sh` | — | ✅ | GoldenGMSA.exe cache/gmsainfo |

---

## Branch B — ADCS + UnPAC

| ID | Phase | Title | Beachhead | Script path | RedStrike intent | Status | Notes |
|----|-------|-------|-----------|-------------|------------------|--------|-------|
| T050 | 5 | ADCS ESC1 | ws01 | `campaign-a/T050-esc1-ws01.sh` | `certify.find` | ✅ | Certify.exe find /vulnerable |
| T051 | 5 | ADCS ESC3 enrollment agent | ws01 | `campaign-a/T051-esc3-ws01.sh` | — | ✅ | Certify.exe request |
| T056 | 5 | ADCS ESC8 (NTLM relay) | ws01 | `campaign-a/T052-esc8-ws01.sh` | — | ✅ | Web enrollment reachability check |
| T-UNPAC | 5 | UnPAC-the-Hash | ws01 | `campaign-a/T053-unpac-thehash-ws01.sh` | — | ✅ | Cert request + Rubeus asktgt /unpac-thehash |

---

## Branch C — SCCM

| ID | Phase | Title | Beachhead | Script path | RedStrike intent | Status | Notes |
|----|-------|-------|-----------|-------------|------------------|--------|-------|
| T034 | 8 | SCCM NAA extraction | ws01 | `campaign-a/T034-sccm-enum-ws01.sh` | `sharpsccm.get_naa` | ✅ | Client setup / NAA check |
| T035 | 8 | SCCM PXE boot abuse | ws01 | `campaign-a/T035-sccm-pxe-boot-ws01.sh` | — | ✅ | WDS role presence check |
| T036 | 8 | SCCM client push relay | ws01 | `campaign-a/T036-sccm-client-push-ws01.sh` | — | ✅ | CcmExec service check |
| T037 | 8 | SCCM CMPivot abuse | ws01 | `campaign-a/T037-sccm-cmpivot-ws01.sh` | — | ✅ | SCCM client binary presence |
| T038 | 8 | SCCM app deploy | ws01 | `campaign-a/T038-sccm-app-deploy-ws01.sh` | — | ✅ | WMI CCM_Application query |
| T039 | 8 | SCCM site takeover | ws01 | `campaign-a/T039-sccm-site-takeover-ws01.sh` | — | ✅ | Site server admin group query |

---

## Branch D — Linux Pivot

| ID | Phase | Title | Beachhead | Script path | RedStrike intent | Status | Notes |
|----|-------|-------|-----------|-------------|------------------|--------|-------|
| T040 | 3 | MSSQL linked server hop → linux01 | ws01 | `campaign-a/T040-mssql-linked-server-hop-ws01.sh` | — | ✅ | sp_helpserver from mbr01 |
| T044 | 3 | MSSQL Linux lateral | linux60 | *(aliases T040)* | — | 📝 | Aliased to T040; needs dedicated Linux lateral script |
| T045 | 3.5 | Linux SSSD ticket extraction | linux60 | *(aliases T040)* | — | 📝 | Aliased to T040; needs dedicated Linux script |
| T047 | 3.5 | NFS Kerberos mount | linux60 | *(aliases T040)* | — | 📝 | Aliased to T040; needs dedicated Linux script |
| T048 | 3.5 | Podman container escape | linux60 | *(aliases T040)* | — | 📝 | Aliased to T040; needs dedicated Linux script |

---

## Branch G — MITRE Gap / Standalone

| ID | Phase | Title | Beachhead | Script path | RedStrike intent | Status | Notes |
|----|-------|-------|-----------|-------------|------------------|--------|-------|
| T031 | 1 | Password spray | external60_phase0 | `attacks/WT031-password-spray.sh` | — | ✅ | kerbrute against dc01 |
| T007 | 5 | RBCD standalone exercise | ws01 | `campaign-a/T007-rbcd-ws01.sh` | — | ✅ | msDS-AllowedToAct check via PowerView |

---

## Stream E — Network Defense (Phase 9)

All run from `external60_phase0` (provisioning). Scripts live in `attack-matrix/04-automation/linux/campaign-e/`.

| ID | Title | Script path | RedStrike | Status | Notes |
|----|-------|-------------|-----------|--------|-------|
| WT069 | DNS DGA | `campaign-e/wt069-dns-dga.sh` | `stream E` | ✅ | Queries 8.8.8.8 |
| WT070 | DNS TXT burst | `campaign-e/wt070-dns-txt.sh` | `stream E` | ✅ | Queries 8.8.8.8 |
| WT071 | DNS NXDOMAIN burst | `campaign-e/wt071-dns-nxdomain.sh` | `stream E` | ✅ | Queries 8.8.8.8 |
| WT072 | DNS TLD abuse | `campaign-e/wt072-dns-tld.sh` | `stream E` | ✅ | Queries 8.8.8.8 |
| WT073 | DNS IP literal | `campaign-e/wt073-dns-ip-literal.sh` | `stream E` | ✅ | Queries 8.8.8.8 |
| WT074 | TLS 1.0 downgrade | `campaign-e/wt074-tls-v1.sh` | `stream E` | ✅ | ncat/openssl client |
| WT075 | SMB admin share | `campaign-e/wt075-smb-admin.sh` | `stream E` | ✅ | SMB ADMIN$ connect |
| WT076 | HTTP suspicious UA | `campaign-e/wt076-http-ua.sh` | `stream E` | ✅ | curl with odd UA |
| WT077 | HTTP exploit path | `campaign-e/wt077-http-exploit-path.sh` | `stream E` | ✅ | curl to known exploit paths |
| WT078 | HTTP content-type mismatch | `campaign-e/wt078-http-content-type.sh` | `stream E` | ✅ | curl + custom content-type |
| WT079 | SSH brute force | `campaign-e/wt079-ssh-brute.sh` | `stream E` | ✅ | hydra against linux01 |
| WT080 | Long connection beacon | `campaign-e/wt080-long-connection.sh` | `stream E` | ✅ | Long-lived curl/nc |
| WT081 | Outbound anomaly | `campaign-e/wt081-outbound-anomaly.sh` | `stream E` | ✅ | Cross-subnet probe |
| WT093 | Ransomware simulation | — | — | 📝 | Stub — impact exercise deferred |

---

## Stream F — Supply Chain (Phase 10)

All run from `external60_phase0` via `_run_f.sh` staging to `linux01`.

| ID | Title | Script path | RedStrike | Status | Notes |
|----|-------|-------------|-----------|--------|-------|
| F01 | Malicious postinstall webhook | `campaign-f/F01-webhook-postinstall.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F02 | TruffleHog download + scan | `campaign-f/F02-trufflehog.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F03 | Workflow injection | `campaign-f/F03-workflow-injection.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F04 | Package patching | `campaign-f/F04-package-patch.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F05 | /tmp download+exec | `campaign-f/F05-tmp-download-exec.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F06 | npm publish worm | `campaign-f/F06-npm-publish-worm.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F07 | Cloud metadata probe | `campaign-f/F07-cloud-metadata.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F08 | Repo weaponization | `campaign-f/F08-repo-weaponize.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F09 | Bundle worm chain | `campaign-f/F09-bundle-worm.sh` | `stream F` | ✅ | npm-threat-emulation scenario |
| F10 | Dependency confusion | `campaign-f/F10-dependency-confusion.sh` | `stream F` | ✅ | npm-threat-emulation scenario |

---

## Summary Counts

| Category | Total | ✅ Validated | 📝 Stubs / Aliased | ❌ Not implemented |
|----------|------:|------------:|-------------------:|------------------:|
| Spine | 15 | 12 | 3 (H-ASSUME, T035-CREDS, T004-BH) | 0 |
| Branch A | 7 | 7 | 0 | 0 |
| Branch B | 4 | 4 | 0 | 0 |
| Branch C | 6 | 6 | 0 | 0 |
| Branch D | 5 | 1 | 4 (aliased to T040) | 0 |
| Branch G | 2 | 2 | 0 | 0 |
| Stream E | 14 | 13 | 1 (WT093) | 0 |
| Stream F | 10 | 10 | 0 | 0 |
| **Total** | **63** | **55** | **8** | **0** |

---

## How to run

### Standalone script (one attack)

```bash
# From provisioning .60
ssh vagrant@192.168.77.60
export PATH=$HOME/.local/bin:$PATH
cd ~/CADRE/attack-matrix/04-automation/linux/campaign-a
bash T003-asrep-ws01.sh
```

### RedStrike orchestrator (full campaign)

```bash
export PATH=$HOME/.local/bin:$HOME/RedStrike/.venv/bin:$PATH
redstrike-campaign start --engage P1_RUN_$(date +%Y%m%d) \
  --cadre-root ~/CADRE --automation-root ~/CADRE/attack-matrix/04-automation/linux \
  --seed ~/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json --beachhead windows

# Approve gates
for gate in persistence dcsync ticket forest acl_write site_takeover; do
  redstrike-campaign approve --gate $gate --engage P1_RUN_$(date +%Y%m%d)
done

# Execute
redstrike-campaign run --engage P1_RUN_$(date +%Y%m%d) \
  --cadre-root ~/CADRE --automation-root ~/CADRE/attack-matrix/04-automation/linux \
  --seed ~/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json \
  --beachhead windows --branch all --phase 0.5-8 --execute --no-stop-on-hitl --prefer-script

# Streams (separate)
redstrike-campaign stream E --engage P1_STREAM_E_$(date +%Y%m%d) \
  --cadre-root ~/CADRE --automation-root ~/CADRE/attack-matrix/04-automation/linux \
  --seed ~/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json --beachhead linux --execute

redstrike-campaign stream F --engage P1_STREAM_F_$(date +%Y%m%d) \
  --cadre-root ~/CADRE --automation-root ~/CADRE/attack-matrix/04-automation/linux \
  --seed ~/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json --beachhead linux --execute
```

---

## Gaps to close for 100% coverage

1. **T035-CREDS** — Add post-SYSTEM mimikatz sekurlsa logonpasswords (or lsassy) on `ws01`.
2. **T004-BH** — Add SharpHound collection from `ws01` as `analyst_t1`.
3. **Branch D** — T044/T045/T047/T048 are currently aliased to T040; write dedicated Linux pivot scripts.
4. **H-ASSUME / WT093** — These are intentionally manual/deferred per campaign design (initial access + impact simulation).
