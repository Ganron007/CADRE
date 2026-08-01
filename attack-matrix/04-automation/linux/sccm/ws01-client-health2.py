# Check MBR02/WS01 client health via CH_ClientSummary — analyst_t1 (ws01)
import pyodbc

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

def q(title, query, limit=20):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
        return rows
    except Exception as e:
        print('ERR: %s' % e)
        return []

q('CH_ClientSummary cols', "SELECT TOP 1 * FROM CH_ClientSummary")
rows = q('MBR02 + WS01', "SELECT * FROM CH_ClientSummary WHERE ResourceID IN (16777219,16777220)")
print('\nCLIENTHEALTH2_DONE')
