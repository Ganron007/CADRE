from pathlib import Path

path = Path(r'C:\STUDY\Github\CADRE-Platform\CADRE\attack-matrix\Campaign\CAMPAIGNS-VALIDATION-REPORT-20260730.md')
text = path.read_text(encoding='utf-8')

blocker_bullet = '''- **Provisioning bridge path:** `/tmp/nxc-venv` on `provisioning` now contains `nxc` and `certipy` installed from git. Use this bridge for attacks that cannot run on `ws01` until the Rust compiler is added or prebuilt wheels are available.
+ **Direct `ws01` SSH:** `localhost -> ws01` SSH via `cadre-ws01-key` is working. `ws01` tooling remains incomplete: `nxc`/`certipy` are absent because `pip install NetExec` returns `No matching distribution found`, and the git install fails on `aardwolf` due to a missing Rust compiler. A working `nxc`/`certipy` bridge is available on `provisioning` at `/tmp/nxc-venv` for attacks that cannot run on `ws01` yet.'''

# Update blocker bullet
old_blocker = '> 3. **Provisioning bridge path:** `/tmp/nxc-venv` on `provisioning` now contains `nxc` and `certipy` installed from git. Use this bridge for attacks that cannot run on `ws01` until the Rust compiler is added or prebuilt wheels are available.'
if old_blocker in text:
    text = text.replace(old_blocker, blocker_bullet.strip())
    print('UPDATED_BLOCKER_BULLET')
else:
    print('NO_BLOCKER_BULLET_MATCH')

old_header = '> **Execution environment blocker (2026-07-31):** Live retest is currently blocked at two layers.'
if old_header in text:
    text = text.replace(old_header, '> **Live retest state (2026-07-31):** Verified the executable attack surface from `ws01` and the `provisioning` bridge.')
    print('UPDATED_HEADER')
else:
    print('NO_HEADER_MATCH')

old_phase1 = '| 003 | AS-REP Roast (WT003) | provisioning bridge | child\\intern_blue / 1nt3rn_Blu3! | ✅ Verified | `ws01` `Rubeus` failed with LDAP operations error; alternate `provisioning` bridge via `/tmp/nxc-venv/bin/nxc ldap ... --asreproast` succeeded and captured `$krb5asrep$23$` hash | No |\n'
new_phase1 = '| 003 | AS-REP Roast (WT003) | provisioning bridge | child\\intern_blue / 1nt3rn_Blu3! | ✅ Verified | `ws01` `Rubeus` failed with LDAP operations error; `provisioning` `/tmp/nxc-venv/bin/nxc ldap ... --asreproast` succeeded and captured `$krb5asrep$23$` | No |\n'
if old_phase1 in text:
    text = text.replace(old_phase1, new_phase1)
    print('UPDATED_PHASE1')
else:
    print('NO_PHASE1_MATCH')

old_phase2 = '| 002 | Kerberoast via ACE#18 bridge (WT002) | provisioning bridge | intern_blue / 1nt3rn_Blu3! | ⏳ Blocked | ACE#18 password reset for `analyst_t2` succeeded via `/tmp/nxc-venv/bin/nxc smb ... -M change-password`, but Kerberoast for `svc_mssql` and `analyst_t1` returns `KDC_ERR_ETYPE_NOSUPP` from `provisioning`; same error seen from `ws01` with `Rubeus`. Downstream `svc_mssql`-dependent attacks are blocked until KDC etype issue is resolved. | Yes — resolve KDC encryption-type support or add alternate `svc_mssql` credential path |\n'
new_phase2 = '| 002 | Kerberoast via ACE#18 bridge (WT002) | provisioning bridge | intern_blue / 1nt3rn_Blu3! | ⏳ Blocked | ACE#18 password reset for `analyst_t2` succeeded via `/tmp/nxc-venv/bin/nxc smb ... -M change-password`, but Kerberoast for `svc_mssql` and `analyst_t1` returns `KDC_ERR_ETYPE_NOSUPP` from `provisioning`; same failure observed from `ws01` with `Rubeus`. | Yes — resolve KDC encryption-type support or add an alternate `svc_mssql` credential path |\n'
if old_phase2 in text:
    text = text.replace(old_phase2, new_phase2)
    print('UPDATED_PHASE2')
else:
    print('NO_PHASE2_MATCH')

old_phase3 = '| 041/043 | SQL xp_cmdshell + GodPotato (WT041/WT043) | ws01 -> mbr01 | child\\analyst_t1 / T13r_An@lyst! | ⠿ Partial | `xp_cmdshell 'whoami'` returns `nt service\\mssql$sqlexpress`; GodPotato escalation blocked because `C:\\Windows\\Temp\\cadre-tools\\GodPotato.exe` is missing on `mbr01` | Yes — stage GodPotato on `mbr01` and rerun |\n'
new_phase3 = '| 041/043 | SQL xp_cmdshell + GodPotato (WT041/WT043) | ws01 -> mbr01 | child\\analyst_t1 / T13r_An@lyst! | ⠿ Partial | `xp_cmdshell 'whoami'` returned `nt service\\mssql$sqlexpress`; SYSTEM escalation is blocked because `C:\\Windows\\Temp\\cadre-tools\\GodPotato.exe` is missing on `mbr01` | Yes — stage `GodPotato-NET4.exe` on `mbr01` and rerun |\n'
if old_phase3 in text:
    text = text.replace(old_phase3, new_phase3)
    print('UPDATED_PHASE3')
else:
    print('NO_PHASE3_MATCH')

old_3_5c = '| 3.5C | RDP interactive session as analyst_cloud (3.5C) | ws01 -> mbr01 | analyst_cloud / Cl0ud_An@lyst! | ⏳ Not exercised | Type 10 logon + SharpHound data | Yes |\n'
new_3_5c = '| 3.5C | RDP interactive session as analyst_cloud (3.5C) | ws01 -> mbr01 | analyst_cloud / Cl0ud_An@lyst! | ⠿ BLOCKED — script missing | No dedicated `3.5C` execution script was found in `attack-matrix/04-automation/`; metadata/routing exist, but test harness is absent | Yes — add/verify script and rerun |\n'
if old_3_5c in text:
    text = text.replace(old_3_5c, new_3_5c)
    print('UPDATED_3_5C')
else:
    print('NO_3_5C_MATCH')

old_3_5a = '| 3.5A | Winlogon plaintext credential extraction (3.5A) | SYSTEM on mbr01 | SYSTEM | ✅ Verified | Extracts CADRE\\analyst_cloud:Cl0ud_An@lyst! from registry | No |\n'
new_3_5a = '| 3.5A | Winlogon plaintext credential extraction (3.5A) | SYSTEM on mbr01 | SYSTEM | ⠿ BLOCKED — missing execution chain | Verification depends on SYSTEM execution helper + `GodPotato`; `GodPotato.exe` is missing on `mbr01`, so `analyst_cloud` registry extraction could not be completed in this retest | Yes — stage `GodPotato-NET4.exe` and rerun |\n'
if old_3_5a in text:
    text = text.replace(old_3_5a, new_3_5a)
    print('UPDATED_3_5A')
else:
    print('NO_3_5A_MATCH')

path.write_text(text, encoding='utf-8')
print('DONE')
