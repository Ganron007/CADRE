# Poll CMPivot results for WS01 (ResourceID 16777220) — analyst_t1 (ws01)
import pyodbc, time

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

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

for i in range(12):
    time.sleep(12)
    print('\n--- poll %d ---' % (i+1))
    q('ClientOperation recent', "SELECT ID, Type, State, Priority, CreatedBy FROM ClientOperation WHERE ID >= 16777231")
    q('CMPivotResult for WS01', "SELECT ID, ResourceID, ScriptExecutionState, ScriptExitCode, ScriptOutput, ErrorMessage, ReturnCode FROM CMPivotResult WHERE ResourceID=16777220")
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM CMPivotResult WHERE ResourceID=16777220")
    if cur.fetchone()[0] > 0:
        print('[+] RESULTS FOUND')
        q('FULL RESULT', "SELECT * FROM CMPivotResult WHERE ResourceID=16777220")
        break
print('\nPOLL_FINAL_DONE')
