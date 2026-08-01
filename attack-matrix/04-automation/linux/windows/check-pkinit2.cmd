@echo off
echo === PKINITtools-master ===
dir /b /s C:\Tools\cadre-attack\pkinittools-src\PKINITtools-master 2>&1 | findstr /i "gettgtpkinit getnthash"
echo === pywhisker-main ===
dir /b C:\Tools\cadre-attack\pywhisker-src\pywhisker-main 2>&1
echo === python scripts dir (full) ===
dir /b C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
