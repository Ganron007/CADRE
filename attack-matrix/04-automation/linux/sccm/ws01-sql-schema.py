# SCCM DB schema discovery — analyst_t1 (ws01 ATTACK)
import pyodbc, sys

conn = None
try:
    cs = ('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;'
          'Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
    conn = pyodbc.connect(cs)
    print('[+] connected')
except Exception as e:
    print('[!] connect err: %s' % e); sys.exit(1)

def q(title, query):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows: print(list(r))
    except Exception as e:
        print('ERR: %s' % e)

q('databases', "SELECT name FROM sys.databases")
q('tables like Admin/Role/Rbac/Secured', "SELECT name FROM sys.tables WHERE name LIKE '%Admin%' OR name LIKE '%Role%' OR name LIKE '%Rbac%' OR name LIKE '%Secured%' OR name LIKE '%Category%'")
print('\nSCHEMA_DONE')
