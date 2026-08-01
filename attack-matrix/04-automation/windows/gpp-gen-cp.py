import base64
from Crypto.Cipher import AES

key = bytes.fromhex('4e9906e8fcb66cc9faf49310620d8e2f0b3c9c5a2ca1f3dbd7d9c2d1e8c0c04a')
password = 's3rv1c3_Ld@p!'
padded = password.encode('utf-16-le').ljust(32, b'\x00')
enc = AES.new(key, AES.MODE_ECB).encrypt(padded)
cp = base64.b64encode(enc).decode()
print('CPASSWORD', cp)
print('LEN', len(cp))

# proper GPP decrypt: decode utf-16-le THEN strip nulls
raw = base64.b64decode(cp)
plain = AES.new(key, AES.MODE_ECB).decrypt(raw)
pw = plain.decode('utf-16-le').rstrip('\x00')
print('ROUNDTRIP', repr(pw))
print('MATCH', pw == password)
