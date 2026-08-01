[CmdletBinding()]
param(
    [string]$TargetHost = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Stop"

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

try {
    $r = Invoke-Command -ComputerName $TargetHost -Credential $cred -ScriptBlock {
        $who = whoami
        $whoamiGroups = whoami /groups
        $adminCheck = (net localgroup administrators) -join "`n"
        $tempWrite = Test-Path "C:\Windows\Temp" -PathType Container
        $testFile = "C:\Windows\Temp\cadre-tools\privtest.txt"
        New-Item -ItemType Directory -Path "C:\Windows\Temp\cadre-tools" -Force -ErrorAction SilentlyContinue | Out-Null
        try {
            Set-Content -Path $testFile -Value "ok" -ErrorAction Stop
            $writeOk = "WRITABLE"
        } catch { $writeOk = "DENIED" }
        [PSCustomObject]@{
            Who = $who
            AdminGroupHasAnalyst = $adminCheck.Contains("analyst_t1")
            TempCadreDir = $tempWrite
            WriteTest = $writeOk
        } | Format-List
    }
    $r | Out-String | Write-Output
} catch {
    Write-Output "CHECK_FAIL: $($_.Exception.Message)"
    exit 1
}
