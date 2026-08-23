[CmdletBinding()]
param()
$dir = "C:\Tools\cadre-attack"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$dst = Join-Path $dir "certipy.exe"
if (-not (Test-Path -LiteralPath $dst)) {
    $src = Get-ChildItem "C:\Users\analyst_t1*\AppData\Local\Programs\Python\Python*\Scripts\certipy.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($src) {
        Copy-Item $src.FullName $dst -Force
    }
}
Get-Item $dst -ErrorAction SilentlyContinue | Select-Object FullName, Length
