# Find script tables + approve WT039 script via DB — analyst_t1 (ws01)
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

q('script tables', "SELECT name FROM sys.tables WHERE name LIKE '%Script%'")

guid = 'de5c9f3d-68f6-446f-88db-7c0a2770afcc'
q('SMS_Scripts row for guid', "SELECT * FROM SMS_Scripts WHERE ScriptGuid='%s'" % guid)
# check other candidate tables
for t in ['SMS_ScriptContent','ScriptContent','SMS_Script','Scripts']:
    try:
        cur = conn.cursor()
        cur.execute("SELECT name FROM sys.tables WHERE name='%s'" % t)
        if cur.fetchone():
            q('%s row for guid' % t, "SELECT * FROM %s WHERE ScriptGuid='%s'" % (t, guid))
    except Exception as e:
        pass
print('\nFIND_DONE')
