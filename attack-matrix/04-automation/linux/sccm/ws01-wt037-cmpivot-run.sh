#!/bin/bash
# WT037 CMPivot from ws01 via SSH
ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key -o StrictHostKeyChecking=no analyst_t1@192.168.77.62 "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\analyst_t1\ws01-wt037-cmpivot.ps1"
