@echo off
python -c "import impacket; print('file:', impacket.__file__)"
python -c "import impacket.tds; print('tds OK')" 2>&1 | findstr /r "OK Error"
python -c "import impacket.krb5.ccache; print('ccache OK')" 2>&1 | findstr /r "OK Error"
python -c "import impacket.spnego; print('spnego OK')" 2>&1 | findstr /r "OK Error"
python -c "import impacket.krb5.asn1; print('asn1 OK')" 2>&1 | findstr /r "OK Error"
python -m pip show impacket 2>&1 | findstr /r "Name Version Location"
echo ===DONE===
