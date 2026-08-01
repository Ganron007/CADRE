# Check MBR02 client health + client operation manager — analyst_t1 (ws01)
import pyodbc

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

def q(title, query, limit=20):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
    except Exception as e:
        print('ERR: %s' % e)

q('client summary tables', "SELECT name FROM sys.tables WHERE name LIKE '%ClientSummary%' OR name LIKE '%CH_ClientSummary%' OR name LIKE '%ClientStatus%'")
q('MBR02 in v_ClientSummary', "SELECT ResourceID, ClientActiveStatus, LastPolicyRequestTime, LastMPServerName, ClientVersion, LastClientCheckTime FROM v_ClientSummary WHERE ResourceID=16777219", 5)
q('WS01 in v_ClientSummary', "SELECT ResourceID, ClientActiveStatus, LastPolicyRequestTime, LastMPServerName, ClientVersion, LastClientCheckTime FROM v_ClientSummary WHERE ResourceID=16777220", 5)
q('ClientOperation component status', "SELECT Name, SiteCode, Status FROM v_ComponentStatus WHERE Name LIKE '%CLIENT_OPERATION%' OR Name LIKE '%MP%' OR Name LIKE '%SMS_MP%'", 20)
print('\nCLIENTHEALTH_DONE')
