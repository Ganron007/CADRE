# RBAC diff: working Full Admin 16777217 (MBR02\vagrant) vs svc_sccm 16777218 — analyst_t1 (ws01)
import pyodbc

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

def q(title, query, limit=100):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query)
        cols = [d[0] for d in cur.description]
        print('cols:', cols)
        rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
        return rows, cols
    except Exception as e:
        print('ERR: %s' % e)
        return [], []

def dump(table, admin_filter, limit=100):
    rows, cols = q('%s for %s' % (table, admin_filter), "SELECT * FROM %s WHERE %s" % (table, admin_filter), limit)
    return rows, cols

A = 'AdminID=16777217'
B = 'AdminID=16777218'

dump('RBAC_Admins', "AdminID IN (16777217,16777218)")
dump('RBAC_ExtendedPermissions', "AdminID IN (16777217,16777218)", 50)
dump('RBAC_CategoryMemberships', "AdminID IN (16777217,16777218)", 50)
dump('RBAC_InstancePermissions', "AdminID IN (16777217,16777218)", 50)
dump('RBAC_AdminExtendedData', "AdminID IN (16777217,16777218)", 50)
dump('RBAC_EnabledAccounts', "AdminID IN (16777217,16777218)", 50)

print('\n=== AuthoringScopeID of real CIs (verify ScopeId format) ===')
q('CI tables', "SELECT name FROM sys.tables WHERE name LIKE '%CI_%' OR name LIKE '%ConfigurationItem%' OR name LIKE '%App%'", 40)
q('existing apps', "SELECT TOP 5 * FROM vSMS_Application", 5)
q('existing CIs w/ AuthoringScopeID', "SELECT TOP 10 CI_UniqueID, AuthoringScopeID, CIType FROM v_CI_ConfigurationItems", 10)
print('\nRBACDIFF_DONE')
