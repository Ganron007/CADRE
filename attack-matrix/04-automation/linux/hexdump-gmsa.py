import sys

data = open('/tmp/gmsa-blob.bin', 'rb').read()
print('TOTAL_LEN', len(data))
for i in range(0, len(data), 16):
    chunk = data[i:i+16]
    hexs = ' '.join(f'{b:02x}' for b in chunk)
    asc = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
    print(f'{i:04x}  {hexs:<47}  {asc}')
