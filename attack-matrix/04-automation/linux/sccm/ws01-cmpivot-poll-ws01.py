# Poll CMPivot results for WS01 op 16777232 — analyst_t1 (ws01)
import pyodbc, time

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
opid = 16777232
print('[+] connected; polling op %d' % opid)

def q(title, query, limit=30):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
        return rows
    except Exception as e:
        print('ERR: %s' % e)
        return []

for i in range(14):
    time.sleep(15)
    print('\n--- poll %d ---' % (i+1))
    q('ClientOperation', "SELECT ID, Type, State, Priority, RequestedTime, TargetType FROM ClientOperation WHERE ID=%d" % opid)
    q('ResourceTarget', "SELECT * FROM ClientOperationResourceTarget WHERE ClientOperationId=%d" % opid)
    q('CMPivotResult for WS01', "SELECT ID, ResourceID, ScriptExecutionState, ScriptExitCode, ScriptOutput, ErrorMessage, ReturnCode FROM CMPivotResult WHERE ResourceID=16777220")
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM CMPivotResult WHERE ResourceID=16777220")
    if cur.fetchone()[0] > 0:
        print('[+] RESULTS FOUND')
        q('FULL RESULT', "SELECT * FROM CMPivotResult WHERE ResourceID=16777220")
        break
print('\nPOLL_WS01_DONE')
