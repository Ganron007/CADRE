# H-campaign setup: build marker payload + download AutoIt3 / WiX / HTML Help Workshop
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'
New-Item -ItemType Directory -Path $www -Force | Out-Null

# ---------- 1. Build marker payload.exe via csc ----------
$cs = @'
using System;
using System.IO;
class P {
  static void Main() {
    string who = Environment.UserDomainName + "\\" + Environment.UserName;
    string line = "H-PAYLOAD|executed as " + who + " at " + DateTime.Now.ToString("s") + "|" + Environment.MachineName;
    File.WriteAllText(@"C:\Windows\Temp\H-PAYLOAD-MARKER.txt", line + Environment.NewLine);
  }
}
'@
Set-Content -Path "$www\payload.cs" -Value $cs -Encoding ASCII
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
& $csc /nologo /out:"$www\payload.exe" "$www\payload.cs" 2>&1 | Select-Object -First 5 | ForEach-Object { Write-Output "CSC|$_" }
Write-Output "PAYLOAD_EXISTS $(Test-Path "$www\payload.exe")"
if (Test-Path "$www\payload.exe") { Write-Output "PAYLOAD_SIZE $((Get-Item "$www\payload.exe").Length)" }

# ---------- 2. Download AutoIt3 portable ----------
Write-Output '=== AUTOIT DOWNLOAD ==='
& curl.exe -L -sS --max-time 120 -o "$www\autoit-v3.zip" 'https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3.zip' 2>&1 | Out-Null
if (Test-Path "$www\autoit-v3.zip") {
    Write-Output "AUTOIT_ZIP $((Get-Item "$www\autoit-v3.zip").Length)"
    Expand-Archive "$www\autoit-v3.zip" "$www\autoit" -Force
    $ai = Get-ChildItem "$www\autoit" -Recurse -Filter 'AutoIt3.exe' | Select-Object -First 1
    if ($ai) {
        Copy-Item $ai.FullName "$www\AutoIt3.exe" -Force
        Write-Output "AUTOIT_EXE $($ai.FullName) -> $www\AutoIt3.exe ($((Get-Item "$www\AutoIt3.exe").Length))"
    } else { Write-Output 'AUTOIT_EXE_MISSING_IN_ZIP' }
}

# ---------- 3. Download WiX 3.14 ----------
Write-Output '=== WIX DOWNLOAD ==='
& curl.exe -L -sS --max-time 180 -o "$www\wix314.zip" 'https://github.com/wixtoolset/wix3/releases/download/wix3141rtm/wix314-binaries.zip' 2>&1 | Out-Null
if (Test-Path "$www\wix314.zip") {
    Write-Output "WIX_ZIP $((Get-Item "$www\wix314.zip").Length)"
    Expand-Archive "$www\wix314.zip" "$www\wix" -Force
    Write-Output "WIX_CANDLE $(Test-Path "$www\wix\candle.exe") LIGHT $(Test-Path "$www\wix\light.exe")"
}

# ---------- 4. Download HTML Help Workshop ----------
Write-Output '=== HHW DOWNLOAD ==='
& curl.exe -L -sS --max-time 120 -o "$www\htmlhelp.exe" 'https://download.microsoft.com/download/0/A/9/0A939EF6-E31C-430F-A3DF-DFAE7960D564/htmlhelp.exe' 2>&1 | Out-Null
if (Test-Path "$www\htmlhelp.exe") {
    Write-Output "HHW_SETUP $((Get-Item "$www\htmlhelp.exe").Length)"
} else { Write-Output 'HHW_DOWNLOAD_FAILED' }

Write-Output '=== WWW DIR ==='
Get-ChildItem $www | Select-Object Name, Length | Format-Table -AutoSize | Out-String
Write-Output 'H_SETUP_DONE'
