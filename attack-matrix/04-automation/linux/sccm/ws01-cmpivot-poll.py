# Poll CMPivot results for OperationID 16777231 from site DB — analyst_t1 (ws01)
import pyodbc, time, sys

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
opid = 16777231
print('[+] connected; polling CMPivotResult for op %d' % opid)

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

# inspect CMPivotResult schema first
rows = q('CMPivotResult schema (top1)', "SELECT TOP 1 * FROM CMPivotResult", 3)
if rows:
    cols = [d[0] for d in conn.cursor().execute("SELECT TOP 1 * FROM CMPivotResult").description]
    print('cols:', cols)

for i in range(12):
    time.sleep(10)
    print('\n--- poll %d ---' % (i+1))
    rows = q('CMPivotResult for op', "SELECT * FROM CMPivotResult WHERE OperationID=%d" % opid, 30)
    if rows:
        # show columns
        cur = conn.cursor()
        cur.execute("SELECT TOP 1 * FROM CMPivotResult WHERE OperationID=%d" % opid)
        cols = [d[0] for d in cur.description]
        print('cols:', cols)
    q('ClientOperation for op', "SELECT * FROM ClientOperation WHERE ID=%d" % opid, 5)
    q('ClientOperationSummary for op', "SELECT * FROM ClientOperationSummary WHERE OperationID=%d OR ID=%d" % (opid, opid), 10)
    q('ClientOperationResourceTarget for op', "SELECT * FROM ClientOperationResourceTarget WHERE OperationID=%d" % opid, 10)
    # check if any result rows exist -> stop early
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM CMPivotResult WHERE OperationID=%d" % opid)
    if cur.fetchone()[0] > 0:
        print('[+] RESULTS FOUND — dumping full')
        q('FULL RESULTS', "SELECT * FROM CMPivotResult WHERE OperationID=%d" % opid, 100)
        break
print('\nPOLL_DONE')
