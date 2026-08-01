Write-Output '=== BGB vdir physical path ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\vdirs' -ErrorAction SilentlyContinue | Select-Object Name | Select-Object -First 30
Write-Output '=== BGB vdir content ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\vdirs\BGB' -Recurse -ErrorAction SilentlyContinue | Select-Object FullName | Select-Object -First 30
Write-Output '=== IIS BGB app ==='
Import-Module WebAdministration -ErrorAction SilentlyContinue
Get-WebApplication -Site 'Default Web Site' -ErrorAction SilentlyContinue | Select-Object Path, PhysicalPath
Write-Output '=== IIS BGB handler mappings ==='
if (Test-Path 'IIS:\Sites\Default Web Site\BGB') {
  Get-WebHandler -Location 'IIS:\Sites\Default Web Site\BGB' -ErrorAction SilentlyContinue | Select-Object Name, Path, Modules
} else { Write-Output 'BGB vdir NOT in IIS' }
Write-Output '=== port 10123 listener ==='
Get-NetTCPConnection -LocalPort 10123 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, State, OwningProcess
netstat -ano | findstr 10123
Write-Output 'BGB_CHECK_DONE'
