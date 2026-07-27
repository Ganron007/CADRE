#!/usr/bin/env bash
# Fix oscrypto OpenSSL 3.0.13+ version regex (Ubuntu 24.04) so nxc protocols load.
set -euo pipefail
PY_SITE="${HOME}/.local/lib/python3.12/site-packages"
OSC="${PY_SITE}/oscrypto/_openssl/_libcrypto_cffi.py"
if [[ ! -f "${OSC}" ]]; then
  echo "oscrypto not installed at ${OSC}" >&2
  exit 1
fi
cp -a "${OSC}" "${OSC}.bak"
python3 - "${OSC}" <<'PY'
import re
import sys
from pathlib import Path
p = Path(sys.argv[1])
lines = p.read_text().splitlines()
patched = False
for i, line in enumerate(lines):
    if line.strip().startswith("version_match = re.search") and "version_string)" in line and "LibreSSL" not in line:
        if r"\d+\.\d+\.\d+" in line:
            print("already patched at line", i + 1)
            patched = True
            break
        lines[i] = "version_match = re.search(r'\\b(\\d+\\.\\d+\\.\\d+[a-z]*)\\b', version_string)"
        patched = True
        print("patched line", i + 1)
        break
if not patched:
    raise SystemExit("oscrypto version_match line not found")
p.write_text("\n".join(lines) + "\n")
PY
python3 -c "from oscrypto._openssl._libcrypto import libcrypto_version_info; print('oscrypto OK', libcrypto_version_info)"
