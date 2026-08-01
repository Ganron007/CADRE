# Approve WT039 script directly in the DB — analyst_t1 (ws01)
import pyodbc

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
guid = 'DE5C9F3D-68F6-446F-88DB-7C0A2770AFCC'

cur = conn.cursor()
cur.execute("SELECT TOP 1 * FROM Scripts WHERE ScriptGuid='%s'" % guid)
cols = [d[0] for d in cur.description]
print('Scripts columns:', cols)

row = cur.fetchone()
if row:
    d = dict(zip(cols, row))
    print('ApprovalState=', d.get('ApprovalState'), '| Feature=', d.get('Feature'), '| ScriptType=', d.get('ScriptType'))

# Set ApprovalState=3 (approved)
cur.execute("UPDATE Scripts SET ApprovalState=3 WHERE ScriptGuid='%s'" % guid)
conn.commit()
print('Updated rows:', cur.rowcount)

# verify
cur.execute("SELECT ScriptGuid, ScriptName, ApprovalState, Author FROM Scripts WHERE ScriptGuid='%s'" % guid)
print('After:', cur.fetchone())
print('APPROVE_DB_DONE')
