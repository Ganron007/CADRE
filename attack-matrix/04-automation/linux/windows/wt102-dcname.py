# WT102 debug - what domain/DC does ws01 resolve via DsGetDcName?
import ctypes
from ctypes import wintypes

# DsGetDcNameW signature
class DOMAIN_CONTROLLER_INFO(ctypes.Structure):
    _fields_ = [
        ("DomainControllerName", ctypes.c_wchar_p),
        ("DomainControllerAddress", ctypes.c_wchar_p),
        ("DomainGuid", ctypes.c_char * 16),
        ("DomainName", ctypes.c_wchar_p),
        ("DnsForestName", ctypes.c_wchar_p),
        ("Flags", wintypes.ULONG),
        ("DcSiteName", ctypes.c_wchar_p),
        ("ClientSiteName", ctypes.c_wchar_p),
    ]

netapi32 = ctypes.WinDLL('netapi32', use_last_error=True)
netapi32.DsGetDcNameW.restype = wintypes.DWORD
netapi32.DsGetDcNameW.argtypes = [wintypes.LPCWSTR, wintypes.LPCWSTR, ctypes.c_void_p,
                                  wintypes.LPCWSTR, wintypes.ULONG, ctypes.POINTER(ctypes.POINTER(DOMAIN_CONTROLLER_INFO))]

dci = ctypes.POINTER(DOMAIN_CONTROLLER_INFO)()
res = netapi32.DsGetDcNameW(None, None, None, None, 0, ctypes.byref(dci))
print('DsGetDcName res', res)
if res == 0 and dci:
    print('DC_NAME', dci.contents.DomainControllerName)
    print('DOMAIN', dci.contents.DomainName)
    print('FOREST', dci.contents.DnsForestName)
    netapi32.NetApiBufferFree(ctypes.cast(dci, ctypes.c_void_p))
else:
    print('DsGetDcName FAILED')

# also GetComputerNameEx DnsFullyQualified
buf = ctypes.create_unicode_buffer(256)
n = wintypes.DWORD(256)
ctypes.WinDLL('kernel32').GetComputerNameExW(3, buf, ctypes.byref(n))
print('COMPUTER_FQDN', buf.value)
print('DEBUG_DONE')
