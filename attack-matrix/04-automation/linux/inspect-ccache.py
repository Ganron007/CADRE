#!/usr/bin/env python3
import sys
sys.path.insert(0, '/tmp/nxc-venv/lib/python3.12/site-packages')
from impacket.krb5.ccache import CCache

cc = CCache.loadFile('/tmp/t008/dc01_keycred.ccache')
print('CREDENTIALS', len(cc.credentials))
for h in cc.credentials:
    client = h['client'].prettyPrint()
    server = h['server'].prettyPrint()
    key = h['key']
    print('CLIENT', client)
    print('SERVER', server)
    print('KEYTYPE', key['keytype'])
