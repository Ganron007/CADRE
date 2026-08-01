# T023 verify: read back the GPO preference file as analyst_cloud (ws01 native)
import io
from impacket.smbconnection import SMBConnection

target = '192.168.77.10'
user = 'analyst_cloud'
password = 'Cl0ud_An@lyst!'
domain = 'cadre.local'
share = 'SYSVOL'
gpo = '{885EE71C-79CD-4006-B7CF-616B449F745B}'
base = f'cadre.local\\Policies\\{gpo}\\Machine\\Preferences'

smb = SMBConnection(target, target)
smb.login(user, password, domain)
print('LOGIN_OK')

# 1) list Preferences
try:
    for f in smb.listPath(share, base):
        print(f'PREF|{f.get_longname()}|{f.get_filesize()}|dir={f.is_directory()}')
except Exception as e:
    print(f'PREF_FAIL|{e}')

# 2) list ScheduledTasks dir
try:
    for f in smb.listPath(share, base + '\\ScheduledTasks'):
        print(f'ST|{f.get_longname()}|{f.get_filesize()}|dir={f.is_directory()}')
except Exception as e:
    print(f'ST_FAIL|{e}')

# 3) read ScheduledTasks.xml if present
try:
    data = io.BytesIO()
    smb.getFile(share, base + '\\ScheduledTasks\\ScheduledTasks.xml', data.write)
    content = data.getvalue().decode('utf-8', errors='replace')
    print('XML_READ_OK')
    print(content[:600])
except Exception as e:
    print(f'XML_FAIL|{e}')

smb.logoff()
print('VERIFY_DONE')
