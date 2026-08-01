# SCCM RBAC: who is admin, roles, scopes, CMPivot — analyst_t1 (ws01 ATTACK)
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

q('RBAC_Admins', "SELECT AdminID, LogonName, IsGroup, AccountType, CreatedBy FROM RBAC_Admins")
q('RBAC_Roles', "SELECT RoleID, RoleName, BuiltIn FROM RBAC_Roles")
q('RBAC_Categories (non-global)', "SELECT CategoryID, CategoryName, CategoryType FROM RBAC_Categories WHERE CategoryType NOT IN (11,48) ")
q('svc_sccm CategoryMemberships', "SELECT * FROM RBAC_CategoryMemberships WHERE AdminID='SMS0001A' OR AdminID IN (SELECT AdminID FROM RBAC_Admins WHERE LogonName LIKE '%svc_sccm%')")
q('svc_sccm admin row', "SELECT * FROM RBAC_Admins WHERE LogonName LIKE '%svc_sccm%' OR LogonName LIKE '%Administrator%' OR LogonName LIKE '%vagrant%'")
print('\nRBAC2_DONE')
