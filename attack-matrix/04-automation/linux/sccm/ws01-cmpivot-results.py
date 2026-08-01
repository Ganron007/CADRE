# Check CMPivotResult by taskguid + WS01 CMPivot execution logs — analyst_t1 (ws01)
import pyodbc

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=mbr02.range.local,1433;DATABASE=CM_CAD;UID=sa;PWD=s@_P@ssw0rd!L@b!;Encrypt=no;TrustServerCertificate=yes;Connection Timeout=8')
print('[+] connected')

def q(title, query, limit=30):
    print('\n=== %s ===' % title)
    try:
        cur = conn.cursor(); cur.execute(query); rows = cur.fetchall()
        if not rows: print('(no rows)')
        for r in rows[:limit]: print(list(r))
    except Exception as e:
        print('ERR: %s' % e)

q('CMPivotResult by taskguid F4D1E07F', "SELECT * FROM CMPivotResult WHERE TaskID='F4D1E07F-1893-4AD0-B8D8-C42B8DC20F1E'")
q('CMPivotResult all rows', "SELECT TOP 20 * FROM CMPivotResult ORDER BY LastUpdateTime DESC")
print('\n--- client logs ---')
print('=== CMPivot.log tail ===')
import subprocess
r = subprocess.run(['powershell','-NoProfile','-Command',"Get-Content 'C:\\Windows\\CCM\\Logs\\CMPivot.log' -Tail 20 -ErrorAction SilentlyContinue"], capture_output=True, text=True)
print(r.stdout)
print('=== Scripts/CCMExec related ===')
r = subprocess.run(['powershell','-NoProfile','-Command',"Get-ChildItem 'C:\\Windows\\CCM\\Logs' | Where-Object { $_.Name -match 'CMPivot|Script|Sensor|Policy' } | Select-Object Name,LastWriteTime | Sort-Object LastWriteTime -Descending | Select-Object -First 10"], capture_output=True, text=True)
print(r.stdout)
print('DB_DONE')
