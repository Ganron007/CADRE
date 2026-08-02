# Download latest SharpDPAPI from community mirror
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'
& curl.exe -L -sS --max-time 90 -o "$out\SharpDPAPI-new.exe" 'https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpDPAPI.exe' 2>&1 | Out-Null
if (Test-Path "$out\SharpDPAPI-new.exe") { Write-Output "SHARPDPAPI_NEW_SIZE $((Get-Item "$out\SharpDPAPI-new.exe").Length)" } else { Write-Output 'SHARPDPAPI_NEW_MISSING' }
Write-Output 'SDP_DL_DONE'
