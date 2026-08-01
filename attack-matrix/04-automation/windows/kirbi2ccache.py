#!/usr/bin/env python3
"""Convert a Rubeus .kirbi (KRB-CRED) to a ccache file usable by impacket-secretsdump -k."""
import sys

from impacket.krb5.ccache import CCache

def main():
    if len(sys.argv) != 3:
        print("usage: kirbi2ccache.py <input.kirbi> <output.ccache>")
        sys.exit(1)
    in_path, out_path = sys.argv[1], sys.argv[2]
    with open(in_path, "rb") as f:
        data = f.read()
    cc = CCache()
    cc.fromKRBCRED(data)
    cc.saveFile(out_path)
    print(f"CCACHE_WRITTEN {out_path} ({len(data)} kirbi bytes)")

if __name__ == "__main__":
    main()
