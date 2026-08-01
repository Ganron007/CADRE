@echo off
echo === CURL NTLM as svc_sccm (status) ===
curl.exe -k -s -o NUL -w "NTLM_SVCSCCM:%%{http_code}\n" --ntlm -u "RANGE\svc_sccm:s3rv1c3_SCCM!" https://mbr02.range.local/AdminService/wmi/SMS_Site
echo === CURL NTLM as svc_sccm (body) ===
curl.exe -k -s --ntlm -u "RANGE\svc_sccm:s3rv1c3_SCCM!" https://mbr02.range.local/AdminService/wmi/SMS_Site
echo.
echo === NTLM_DONE ===
