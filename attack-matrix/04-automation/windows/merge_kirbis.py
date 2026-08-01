#!/usr/bin/env python3
"""Merge multiple kirbi (KRB-CRED) files into a single ccache."""
import sys

from impacket.krb5.ccache import CCache

def main():
    if len(sys.argv) < 3:
        print("usage: merge_kirbis.py <out.ccache> <in1.kirbi> [in2.kirbi ...]")
        sys.exit(1)
    out_path = sys.argv[1]
    cc = CCache()
    for kirbi in sys.argv[2:]:
        with open(kirbi, "rb") as f:
            cc.fromKRBCRED(f.read())
    cc.saveFile(out_path)
    print(f"MERGED {len(sys.argv)-2} tickets -> {out_path}")

if __name__ == "__main__":
    main()
