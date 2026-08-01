@echo off
echo RAN_AT_%TIME% > C:\Tools\cadre-attack\cn-test.txt
whoami >> C:\Tools\cadre-attack\cn-test.txt 2>&1
whoami /groups | findstr /i "S-1-5-21" >> C:\Tools\cadre-attack\cn-test.txt 2>&1
echo DONE >> C:\Tools\cadre-attack\cn-test.txt
