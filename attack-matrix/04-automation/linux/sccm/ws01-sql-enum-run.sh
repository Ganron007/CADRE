#!/bin/bash
# SCCM DB enum via sa (python impacket.tds)
ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key -o StrictHostKeyChecking=no analyst_t1@192.168.77.62 "python C:\Users\analyst_t1\ws01-sql-enum.py"
