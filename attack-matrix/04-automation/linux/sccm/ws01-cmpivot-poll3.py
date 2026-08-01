# Poll CMPivot results correctly — analyst_t1 (ws01)
import pyodbc, time

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
opid = 16777231
taskid = '{10fa2777-f3b7-4455-8489-bffc0ec2b09c}'

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

for i in range(10):
    time.sleep(15)
    print('\n--- poll %d ---' % (i+1))
    q('ClientOperation 16777231', "SELECT ID, Type, State, Priority, CreatedBy, TargetType FROM ClientOperation WHERE ID=%d" % opid)
    q('ResourceTarget', "SELECT * FROM ClientOperationResourceTarget WHERE ClientOperationId=%d" % opid)
    q('CMPivotResult (TaskID)', "SELECT ID, ResourceID, ScriptExecutionState, ScriptExitCode, ScriptOutput, ErrorMessage FROM CMPivotResult WHERE TaskID='%s'" % taskid)
    q('CMPivotResult (any for MBR02)', "SELECT ID, TaskID, ResourceID, ScriptExecutionState, ScriptExitCode, ScriptOutput FROM CMPivotResult WHERE ResourceID=16777219")
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM CMPivotResult WHERE ResourceID=16777219")
    if cur.fetchone()[0] > 0:
        print('[+] RESULTS!')
        q('FULL', "SELECT * FROM CMPivotResult WHERE ResourceID=16777219")
        break
print('\nPOLL3_DONE')
