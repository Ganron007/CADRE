import sys

def md4(data: bytes) -> bytes:
    import struct
    A, B, C, D = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476
    F = lambda x, y, z: (x & y) | (~x & z)
    G = lambda x, y, z: (x & y) | (x & z) | (y & z)
    H = lambda x, y, z: x ^ y ^ z
    shifts = [
        [3, 7, 11, 19] * 4,
        [3, 5, 9, 13] * 4,
        [3, 9, 11, 15] * 4,
    ]
    msg = bytearray(data)
    ml = len(msg) * 8
    msg.append(0x80)
    while len(msg) % 64 != 56:
        msg.append(0)
    msg += struct.pack('<Q', ml & 0xFFFFFFFFFFFFFFFF)

    def rol(x, n):
        return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF

    for off in range(0, len(msg), 64):
        block = msg[off:off + 64]
        X = list(struct.unpack('<16I', block))
        a, b, c, d = A, B, C, D
        for i in range(16):
            k = i
            a = rol((a + F(b, c, d) + X[k]) & 0xFFFFFFFF, shifts[0][i % 4])
            a, b, c, d = d, a, b, c
        for i in range(16):
            k = (i % 4) * 4 + (i // 4)
            a = rol((a + G(b, c, d) + X[k] + 0x5A827999) & 0xFFFFFFFF, shifts[1][i % 4])
            a, b, c, d = d, a, b, c
        order3 = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]
        for i in range(16):
            k = order3[i]
            a = rol((a + H(b, c, d) + X[k] + 0x6ED9EBA1) & 0xFFFFFFFF, shifts[2][i % 4])
            a, b, c, d = d, a, b, c
        A = (A + a) & 0xFFFFFFFF
        B = (B + b) & 0xFFFFFFFF
        C = (C + c) & 0xFFFFFFFF
        D = (D + d) & 0xFFFFFFFF
    return struct.pack('<4I', A, B, C, D)

# RFC 1320 test vectors
vectors = {
    b'': '31d6cfe0d16ae931b73c59d7e0c089c0',
    'a'.encode(): 'bde52cb31de33e46245e05fbdbd6fb24',
    'abc'.encode(): 'a448017aaf21d8525fc10ae87aa6729d',
    'message digest'.encode(): 'd9130a8164549fe818874806e1c7014b',
    'abcdefghijklmnopqrstuvwxyz'.encode(): 'd79e1c308aa5bbcdeea8ed63df412da9',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'.encode(): '043f8582f241db351ce627e153e7f0e4',
    '12345678901234567890123456789012345678901234567890123456789012345678901234567890'.encode(): 'e33b4ddc9c38f2199c3e7b164fcc0536',
}
ok = True
for k, expected in vectors.items():
    got = md4(k).hex()
    status = 'PASS' if got == expected else 'FAIL'
    if got != expected:
        ok = False
    print(status, repr(k[:20]), got, expected)
print('ALL_PASS' if ok else 'HAS_FAILURES')
