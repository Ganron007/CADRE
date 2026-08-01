#!/bin/bash
# Prove functional AdminService access via the CD ST (run ON provisioning)
CC=/tmp/administrator@HTTP_mbr02.range.local@RANGE.LOCAL.ccache
echo '=== 1. SMS_Site (WMI endpoint) — body ==='
KRB5CCNAME=$CC curl -k -s --negotiate -u : --max-time 20 "https://mbr02.range.local/AdminService/wmi/SMS_Site" 2>&1 | head -c 1200
echo
echo
echo '=== 2. REST v1.0 SMS_Site — status + first 800 bytes ==='
KRB5CCNAME=$CC curl -k -s --negotiate -u : --max-time 20 "https://mbr02.range.local/AdminService/v1.0/SMS_Site" 2>&1 | head -c 800
echo
echo
echo '=== 3. Create a test script via AdminService (WT039 staging) ==='
GUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
BODY="{\"ScriptGuid\":\"$GUID\",\"ScriptName\":\"cadre-wt039-probe\",\"Description\":\"WT039 verification via CD\",\"Script\":\"whoami\",\"Language\":\"PowerShell\"}"
echo "POST SMS_Scripts guid=$GUID"
KRB5CCNAME=$CC curl -k -s -o /tmp/sms_scripts_resp.txt -w 'HTTP:%{http_code}\n' --negotiate -u : --max-time 20 -H 'Content-Type: application/json' -d "$BODY" "https://mbr02.range.local/AdminService/v1.0/SMS_Scripts" 2>&1
head -c 800 /tmp/sms_scripts_resp.txt
echo
