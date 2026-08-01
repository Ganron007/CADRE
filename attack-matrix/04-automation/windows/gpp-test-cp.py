import base64
import sys
from Crypto.Cipher import AES

key = bytes.fromhex('4e9906e8fcb66cc9faf49310620d8e2f0b3c9c5a2ca1f3dbd7d9c2d1e8c0c04a')
candidates = [
    'T6Zc9T0qO/pEh+eOXTnxky0jSJvWvPcvAKWwGSpFOqY',
    'T6Zc9T0qO/pEh+eOXTnxky0jSJvWvPcvAKWwGSpFOqY=',
    'T6Zc9T0qO/pEh+eOXTnxky0jSJvWvPcvAKWwGSpFOqY==',
]
for c in candidates:
    try:
        raw = base64.b64decode(c)
        print('LEN', len(raw), raw.hex())
        plain = AES.new(key, AES.MODE_ECB).decrypt(raw)
        print('PLAIN', repr(plain))
    except Exception as e:
        print('ERR', c, e)
print('DONE')
