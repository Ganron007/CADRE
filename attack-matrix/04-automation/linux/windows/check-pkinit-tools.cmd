@echo off
echo === pkinittools-src ===
dir /b C:\Tools\cadre-attack\pkinittools-src 2>&1
echo === pywhisker-src ===
dir /b C:\Tools\cadre-attack\pywhisker-src 2>&1
echo === minikerberos pkinits ===
dir /b C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts | findstr /i "pkinit ntlm"
echo === check openSSL ===
dir /b C:\Tools\cadre-attack\openssl 2>&1
echo === certipy check via pip ===
pip show certipy-ad 2>&1
