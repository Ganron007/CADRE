# Restore cadre.local AdminSDHolder DACL from pristine range.local template.
# range.local (dc03) is a sibling Server 2025 forest with the default AdminSDHolder DACL.
# Steps:
#   1. Read range.local AdminSDHolder SDDL (svc_naa, DA in range.local)
#   2. Translate range domain SID -> cadre domain SID
#   3. Re-add analyst_cloud WriteDacl surface ACE (from 05-ad-attack-surface.yml)
#   4. Write back to cadre.local AdminSDHolder as chief_command (DA)
$ErrorActionPreference = 'Stop'

. C:\Tools\ADTools\ADModule-master\Import-ActiveDirectory.ps1
Import-ActiveDirectory

$rangeUser = 'range.local\svc_naa'
$rangePass = 'N@A_s3rv1c3!'
$rangeDc = '192.168.77.12'
$cadreUser = 'cadre.local\chief_command'
$cadrePass = 'C0mm@nd_Ch1ef!'
$cadreDc = '192.168.77.10'

$rangeSidPrefix = 'S-1-5-21-216814798-3147655578-995453258'
$cadreSidPrefix = 'S-1-5-21-277764030-1371232215-1561074416'
$analystCloudSid = 'S-1-5-21-277764030-1371232215-1561074416-1118'

# --- 1. Read pristine template from range.local ---
$de = New-Object System.DirectoryServices.DirectoryEntry(
    "LDAP://$rangeDc/CN=AdminSDHolder,CN=System,DC=range,DC=local", $rangeUser, $rangePass)
$sd = $de.ObjectSecurity
$rangeSddl = $sd.GetSecurityDescriptorSddlForm('All')
Write-Output "RANGE_SDDL_OK length=$($rangeSddl.Length)"

# --- 2. Translate domain SIDs ---
$translated = $rangeSddl.Replace($rangeSidPrefix, $cadreSidPrefix)
Write-Output "TRANSLATED length=$($translated.Length)"

# --- 3. Re-add analyst_cloud WriteDacl ACE (surface) ---
# Insert before the closing ')' of the DACL section. The DACL starts at "D:PAI(".
$daclStart = $translated.IndexOf('D:')
if ($daclStart -lt 0) { throw 'No DACL section found' }
$daclBodyStart = $translated.IndexOf('(', $daclStart)
if ($daclBodyStart -lt 0) { throw 'No DACL body found' }
$head = $translated.Substring(0, $daclBodyStart)
$body = $translated.Substring($daclBodyStart)
$extraAce = "(A;;WD;;;$analystCloudSid)"
$finalSddl = $head + $extraAce + $body
Write-Output "FINAL_SDDL_OK length=$($finalSddl.Length)"

# --- 4. Write back via Set-ADObject ---
$secpass = ConvertTo-SecureString $cadrePass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($cadreUser, $secpass)
$targetSd = New-Object System.DirectoryServices.ActiveDirectorySecurity
$targetSd.SetSecurityDescriptorSddlForm($finalSddl)

Set-ADObject -Identity 'CN=AdminSDHolder,CN=System,DC=cadre,DC=local' `
    -Replace @{ nTSecurityDescriptor = $targetSd } `
    -Server $cadreDc -Credential $cred -Verbose
Write-Output 'RESTORE_COMMIT_OK'
