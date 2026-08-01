# Poll CMPivot results for WS01 with long wait — analyst_t1 (ws01)
import pyodbc, time

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected; waiting for CMPivot results...')

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

guids = "'F4D1E07F-1893-4AD0-B8D8-C42B8DC20F1E','AF0E7D27-F729-480A-85ED-056D161ED1FB'"
for i in range(12):
    time.sleep(15)
    print('\n--- poll %d ---' % (i+1))
    q('CMPivotResult by taskguids', "SELECT * FROM CMPivotResult WHERE TaskID IN (%s)" % guids)
    q('CMPivotResult by ResourceID', "SELECT ID, TaskID, ResourceID, ScriptExecutionState, ScriptExitCode, ScriptOutput, ErrorMessage FROM CMPivotResult WHERE ResourceID=16777220")
    q('ClientOperation states', "SELECT ID, Type, State, Priority FROM ClientOperation WHERE ID IN (16777231,16777232,16777234)")
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM CMPivotResult WHERE ResourceID=16777220")
    if cur.fetchone()[0] > 0:
        print('[+] RESULTS FOUND')
        q('FULL RESULT', "SELECT * FROM CMPivotResult WHERE ResourceID=16777220")
        break
print('\nPOLL_LONG_DONE')
