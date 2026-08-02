# Cat pypykatz raw output from mbr01
$ErrorActionPreference = 'Continue'
Get-Content 'C:\Windows\Temp\pypykatz-out.txt' -Raw -ErrorAction SilentlyContinue
Write-Output '---CAT_END---'
