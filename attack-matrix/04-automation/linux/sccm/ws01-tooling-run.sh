#!/bin/bash
# Run ws01 tooling + AdminService test
ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key -o StrictHostKeyChecking=no analyst_t1@192.168.77.62 "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\analyst_t1\ws01-tooling.ps1"
