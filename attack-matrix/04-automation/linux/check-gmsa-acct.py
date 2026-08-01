import sys

from ldap3 import Server, Connection, NTLM, ALL
server = Server('192.168.77.10', port=636, use_ssl=True, get_info=ALL)
conn = Connection(server, user='cadre.local\\eng_cloud', password='Cl0ud_Eng!', authentication=NTLM, auto_bind=True)
conn.search('DC=cadre,DC=local',
            '(sAMAccountName=gmsaTools$)',
            attributes=['userAccountControl', 'objectClass', 'msDS-GroupMSAMembership',
                        'SamAccountName', 'distinguishedName',
                        'operatingSystem', 'pwdLastSet', 'dNSHostName'])
for e in conn.entries:
    print('DN', e.entry_dn)
    for attr in ('userAccountControl', 'objectClass', 'msDS-GroupMSAMembership', 'SamAccountName', 'distinguishedName', 'operatingSystem', 'pwdLastSet', 'dNSHostName'):
        try:
            print(attr, repr(e[attr].value))
        except Exception as ex:
            print(attr, 'ERR', ex)
conn.unbind()
