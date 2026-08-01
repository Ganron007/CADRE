import base64
import struct

# Pure-python MD4 (RFC 1320) — OpenSSL 3 removed MD4
def md4(data: bytes) -> bytes:
    import math
    A, B, C, D = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476
    F = lambda x, y, z: (x & y) | (~x & z)
    G = lambda x, y, z: (x & y) | (x & z) | (y & z)
    H = lambda x, y, z: x ^ y ^ z
    # 3 rounds shift amounts
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
        # Round 1
        for i in range(16):
            k = i
            a = rol((a + F(b, c, d) + X[k]) & 0xFFFFFFFF, shifts[0][i % 4])
            a, b, c, d = d, a, b, c
        # Round 2
        for i in range(16):
            k = (i % 4) * 4 + (i // 4)
            a = rol((a + G(b, c, d) + X[k] + 0x5A827999) & 0xFFFFFFFF, shifts[1][i % 4])
            a, b, c, d = d, a, b, c
        # Round 3
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

b = base64.b64decode('PuKq34N/tuN0d9l2EMGEAw55z9y1zbgFbzXM198TkvGbpQA76xaAY0PXe3c4FD4sUXcsdkkJBufnpplUKa1PZpJm1FQy4N3fB63oLK0ZaeJWyFwnO7eiYzNQkbsXWn1Hx65fsuqjD4KqJyyko1T8XGxsqVebXA0FOrXm0TAZrlUtNDqJuNqddqHUzhE85AaIknA8G5hq+3K1SBo9X0IfHA7dZ3E4ZLAeYpIEM4pAr3MUVnxkG87wiOG6GLw5eUqnwjVT9Z11xYlYWZ4QRAEp2H/E78npVSL3zvAUmXjOFzkBb60TDKSJ3ghhoVJSKAbmLINdBOQtxNUDeb7Yz7SGtA==')
s = b.decode('utf-16-le', errors='ignore')
nt = md4(s.encode('utf-16-le')).hex()
open('/tmp/gmsa-nt.txt', 'w').write(nt)
print('PW_LEN', len(s))
print('NTHASH', nt)
