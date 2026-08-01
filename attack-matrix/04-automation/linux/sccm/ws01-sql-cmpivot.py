# Check CMPivot-related tables in site DB — analyst_t1 (ws01)
import pyodbc

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

def q(title, query, limit=30):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
    except Exception as e:
        print('ERR: %s' % e)

q('CMPivot tables', "SELECT name FROM sys.tables WHERE name LIKE '%CMPivot%' OR name LIKE '%ClientOperation%' OR name LIKE '%CMPivotResult%'")
q('SMS_ClientOperation rows', "SELECT TOP 10 * FROM SMS_ClientOperation")
print('\nDB_DONE')
