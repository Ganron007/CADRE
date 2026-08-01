#!/bin/bash
ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key -o StrictHostKeyChecking=no analyst_t1@192.168.77.62 "python C:\Users\analyst_t1\ws01-sql-schema.py"
