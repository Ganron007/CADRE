# Dry-run: does patch-validation-report.py's old_strings still match the current report?
from pathlib import Path

rep = Path(r'C:\STUDY\Github\CADRE-Platform\CADRE\attack-matrix\Campaign\CAMPAIGNS-VALIDATION-REPORT.md')
t = rep.read_text(encoding='utf-8')

checks = {
    'blocker_bullet_old': '> 3. **Provisioning bridge path:** `/tmp/nxc-venv` on `provisioning` now contains `nxc`',
    'header_old': '> **Execution environment blocker (2026-07-31):** Live retest is currently blocked at two layers.',
    'phase1_old': 'Rubeus failed with LDAP operations error; alternate `provisioning` bridge',
    'phase2_old': 'ACE#18 password reset for `analyst_t2` succeeded via `/tmp/nxc-venv/bin/nxc smb',
    'phase3_old': 'GodPotato escalation blocked because `C:\\Windows\\Temp\\cadre-tools\\GodPotato.exe` is missing on `mbr01`',
    '3_5c_old': 'Type 10 logon + SharpHound data',
    '3_5a_old': 'Extracts CADRE\\analyst_cloud:Cl0ud_An@lyst! from registry | No |',
}
for k, v in checks.items():
    print(('MATCH     ' if v in t else 'NO_MATCH  ') + k)
print('CHECK_DONE')
