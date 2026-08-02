# cleanup on ws01: remove 3.5G temp scripts + dc01 staged files via WinRM
$ErrorActionPreference = 'Continue'
Get-ChildItem 'C:\Tools' -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^wt035g|^wt-crte' } | ForEach-Object { Remove-Item $_.FullName -Force; Write-Output "RM_WS01 $($_.Name)" }

$dc = 'dc01.cadre.local'
$user = 'cadre.local\chief_command'
$pass = 'C0mm@nd_Ch1ef!'
$securePass = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $securePass)
try {
  Invoke-Command -ComputerName $dc -Credential $cred -ScriptBlock {
    Remove-Item 'C:\Windows\Temp\sdp-crte.exe','C:\Windows\Temp\ntds-crte.pvk' -Force -ErrorAction SilentlyContinue
    'DC01_CLEANED'
  } | ForEach-Object { Write-Output $_ }
} catch { Write-Output "DC01_CLEAN_FAIL $($_.Exception.Message)" }
Write-Output 'CLEANUP_DONE'
