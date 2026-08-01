from ldap3 import Server, Connection, NTLM, ALL

s = Server('192.168.77.10', port=636, use_ssl=True, get_info=ALL)
c = Connection(s, user='cadre.local\\analyst_cloud', password='Cl0ud_An@lyst!', authentication=NTLM, auto_bind=True)
for acct in ('svc_backup', 'svc_ldap'):
    c.search('DC=cadre,DC=local', '(sAMAccountName=%s)' % acct, attributes=['sAMAccountName', 'userAccountControl', 'description'])
    for e in c.entries:
        print('FOUND', acct, 'UAC', e.userAccountControl.value)
    if not c.entries:
        print('NOT_FOUND', acct)
c.unbind()
print('DONE')
