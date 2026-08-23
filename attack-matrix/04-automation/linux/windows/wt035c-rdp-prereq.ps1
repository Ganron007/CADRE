# 3.5C — RDP interactive session prereqs (Rule 3: auth + port, not full mstsc GUI)
# From ws01: verify mbr01 :3389 reachable + CADRE\analyst_cloud cred authenticates.
$target = '192.168.77.22'
$user = 'CADRE\analyst_cloud'
$pass = 'Cl0ud_An@lyst!'

Write-Output '=== 3.5C RDP port check ==='
$tnc = Test-NetConnection -ComputerName $target -Port 3389 -WarningAction SilentlyContinue
Write-Output ('RDP_PORT_OPEN=' + $tnc.TcpTestSucceeded)

Write-Output '=== 3.5C credential auth (IPC$ SMB) ==='
net use "\\$target\IPC$" /user:$user $pass 2>&1 | ForEach-Object { Write-Output $_.ToString() }
$ipcOk = (net use 2>&1 | Select-String -Pattern 'mbr01|192.168.77.22' -Quiet)
Write-Output ('IPC_AUTH_OK=' + $ipcOk)
if ($ipcOk) { net use "\\$target\IPC$" /delete /y 2>&1 | Out-Null }

Write-Output '=== 3.5C WinRM smoke (optional) ==='
try {
    $cred = New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $pass -AsPlainText -Force))
    $r = Invoke-Command -ComputerName $target -Credential $cred -ScriptBlock { whoami } -ErrorAction Stop
    Write-Output ('WINRM_WHOAMI=' + $r)
    Write-Output 'WINRM_OK=True'
} catch {
    Write-Output ('WINRM_OK=False|' + $_.Exception.Message)
}

Write-Output 'WT035C_PREREQ_DONE'
if ($tnc.TcpTestSucceeded -and $ipcOk) {
    Write-Output 'T035C_OK'
} else {
    Write-Output 'T035C_FAIL: RDP port or IPC$ auth not proved'
    exit 1
}
