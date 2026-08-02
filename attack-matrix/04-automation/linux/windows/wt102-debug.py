# WT102 debug - inspect ws01 computer object + golden TGT import
import sys
from ldap3 import Server, Connection, NTLM, ALL

print('--- wt102b-1-tgt.out (last 12 lines) ---')
try:
    with open(r'C:\Tools\ADTools\wt102b-1-tgt.out', 'r', errors='replace') as f:
        lines = f.readlines()
    for ln in lines[-12:]:
        print(ln.rstrip())
except Exception as e:
    print('ERR reading tgt file:', e)

print('--- ws01 computer object (child domain) ---')
s = Server('192.168.77.11', port=636, use_ssl=True, get_info=ALL)
c = Connection(s, user='child.cadre.local\\analyst_t1', password='T13r_An@lyst!', authentication=NTLM, auto_bind=True)
c.search('DC=child,DC=cadre,DC=local', '(sAMAccountName=ws01$)', attributes=['name', 'samAccountName', 'dNSHostName', 'userAccountControl', 'objectCategory', 'operatingSystem'])
for e in c.entries:
    print('DN', e.entry_dn)
    for a in e.entry_attributes:
        print(' ', a, '=', e[a].value)
c.unbind()
print('DEBUG_DONE')
