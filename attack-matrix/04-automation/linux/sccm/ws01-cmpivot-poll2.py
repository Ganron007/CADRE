# Inspect CMPivot/ClientOperation table schemas + poll — analyst_t1 (ws01)
import pyodbc, time

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
opid = 16777231

def cols(table):
    cur = conn.cursor()
    cur.execute("SELECT TOP 1 * FROM %s" % table)
    return [d[0] for d in cur.description]

for t in ['CMPivotResult','ClientOperation','ClientOperationSummary','ClientOperationResourceTarget','ClientOperationTarget_G']:
    try:
        print(t, '=>', cols(t))
    except Exception as e:
        print(t, 'ERR', e)

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

# discover which column references the operation
for i in range(10):
    time.sleep(10)
    print('\n--- poll %d ---' % (i+1))
    q('ClientOperation', "SELECT ID, Type, State, Priority, RequestedTime, StateDetail FROM ClientOperation WHERE ID=%d" % opid)
    q('CMPivotResult', "SELECT * FROM CMPivotResult", 30)
    q('ClientOperationSummary', "SELECT * FROM ClientOperationSummary", 10)
print('\nPOLL2_DONE')
