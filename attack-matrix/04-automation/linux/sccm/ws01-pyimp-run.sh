#!/bin/bash
# Check impacket core modules on ws01
ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key -o StrictHostKeyChecking=no analyst_t1@192.168.77.62 "cmd /c C:\Users\analyst_t1\ws01-pyimp.cmd"
