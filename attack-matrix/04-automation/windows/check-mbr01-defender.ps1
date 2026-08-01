[CmdletBinding()]
param(
    [string]$TargetHost = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Continue"

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))
try {
    $session = New-PSSession -ComputerName $TargetHost -Credential $cred -ErrorAction Stop
    Write-Output "PSSESSION_OK"
} catch {
    Write-Output "PSSESSION_FAIL: $($_.Exception.Message)"
    exit 1
}

# Check state
$state = Invoke-Command -Session $session -ScriptBlock {
    $st = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($st) {
        Write-Output "RTP=$($st.RealTimeProtectionEnabled) TP=$($st.IsTamperProtected) AV=$($st.AntivirusEnabled) AMSvc=$($st.AMServiceEnabled)"
    } else {
        Write-Output "NO_MP_STATUS"
    }
    $svc = Get-Service WinDefend -ErrorAction SilentlyContinue
    if ($svc) {
        $sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'").StartMode
        Write-Output "WINDEFEND=$($svc.Status)|startmode=$sm"
    } else {
        Write-Output "WINDEFEND_SERVICE_MISSING"
    }
    $pol = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -ErrorAction SilentlyContinue
    Write-Output "POLICY_DISABLE_ANTISPYWARE $($pol.DisableAntiSpyware)"
}
$state | ForEach-Object { Write-Output "STATE|$_" }

Remove-PSSession $session
