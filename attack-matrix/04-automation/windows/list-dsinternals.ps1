# Check DSInternals available functions on dc01
$ErrorActionPreference = 'Continue'
$tools = 'C:\Windows\Temp\cadre-tools'
$dst = Join-Path $tools 'DSInternals_v4.7'
if (-not (Test-Path "$dst\DSInternals.psd1")) { Expand-Archive -Force (Join-Path $tools 'DSInternals_v4.7.zip') $dst }
Import-Module "$dst\DSInternals.psd1" -Force -ErrorAction SilentlyContinue
Write-Output "LOADED_OK"
Get-Command -Module DSInternals -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | Sort-Object | Out-String | Write-Output
Write-Output 'DONE'
