# Reflect PublishingPath ValidatePattern attribute to get the regex — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

$cmd = Get-Command Set-CMActiveDirectoryForest
$p = $cmd.Parameters['PublishingPath']
foreach ($a in $p.Attributes) {
  Write-Output ("  Attr type: " + $a.GetType().FullName)
  # dump all properties
  $a | Get-Member -MemberType Property, Field | ForEach-Object {
    try {
      $v = $a.($_.Name)
      Write-Output ("    " + $_.Name + " = " + $v)
    } catch { Write-Output ("    " + $_.Name + " = (err)") }
  }
}
Write-Output 'REFLECT_DONE'
