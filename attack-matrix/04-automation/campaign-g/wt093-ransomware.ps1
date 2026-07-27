# CADRE — WT093 — Ransomware Simulation
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT093 - Ransomware Simulation"
start_attack "093" "Ransomware Simulation"
step "Create test files"
1..5 | ForEach-Object { Set-Content "C:\Shares\public\test$_.txt" -Value "Test content WT093" }
step "Encrypt with AES-256 (known key for recovery)"
$key = [byte[]]@(0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x10)
$aes = [System.Security.Cryptography.Aes]::Create(); $aes.Key = $key
Get-ChildItem 'C:\Shares\public\test*.txt' | ForEach-Object {
    $c = [System.IO.File]::ReadAllBytes($_.FullName)
    $e = $aes.CreateEncryptor().TransformFinalBlock($c,0,$c.Length)
    [System.IO.File]::WriteAllBytes("$($_.FullName).cadre", $e)
    Remove-Item $_.FullName
}
run_cmd "Get-ChildItem 'C:\Shares\public\*.cadre' | Select-Object Name, Length"
step "Clean up"
run_cmd "Remove-Item 'C:\Shares\public\*.cadre' -Force"
result 0 "WT093 — check Sysmon EID 11 (mass .cadre creates), Endpoint.events.file-*"
