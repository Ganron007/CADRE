# T023 cleanup: remove test GPO preference as analyst_cloud
from impacket.smbconnection import SMBConnection

target = '192.168.77.10'
user = 'analyst_cloud'
password = 'Cl0ud_An@lyst!'
domain = 'cadre.local'
share = 'SYSVOL'
gpo = '{885EE71C-79CD-4006-B7CF-616B449F745B}'
fpath = f'cadre.local\\Policies\\{gpo}\\Machine\\Preferences\\ScheduledTasks\\ScheduledTasks.xml'

smb = SMBConnection(target, target)
smb.login(user, password, domain)
print('LOGIN_OK')
try:
    smb.deleteFile(share, fpath)
    print('DELETED')
except Exception as e:
    print(f'DELETE_FAIL|{e}')
# remove empty dir
try:
    smb.deleteFile(share, f'cadre.local\\Policies\\{gpo}\\Machine\\Preferences\\ScheduledTasks')
    print('DIR_DELETED')
except Exception as e:
    print(f'DIR_DELETE_FAIL|{e}')
smb.logoff()
print('CLEANUP_DONE')
