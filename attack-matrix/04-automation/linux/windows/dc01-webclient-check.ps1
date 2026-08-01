# Check dc01 WebClient service + spooler registry hardening keys
$ErrorActionPreference = "Continue"
$env:PYTHONIOENCODING = "utf-8"
$secpwd = ConvertTo-SecureString "C0mm@nd_Ch1ef!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("cadre.local\chief_command", $secpwd)

Write-Output "=== dc01 WebClient + Spooler via WMI ==="
foreach ($svc in "WebClient","Spooler","LanmanServer") {
  try {
    $s = Get-WmiObject -Class Win32_Service -ComputerName dc01.cadre.local -Credential $cred -Filter "Name='$svc'" -ErrorAction Stop
    $s | Format-List Name,State,StartMode
  } catch {
    Write-Output "$svc query failed: $($_.Exception.Message)"
  }
}

Write-Output "=== dc01 spooler hardening keys (via WMI registry) ==="
try {
  $k1 = Get-WmiObject -Namespace "root\default" -Class StdRegProv -ComputerName dc01.cadre.local -Credential $cred -ErrorAction Stop
  $paths = @(
    "HKLM\SYSTEM\CurrentControlSet\Control\Print",
    "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
  )
  foreach ($p in $paths) {
    $hive = $p.Split("\")[0]
    $key = $p.Substring($p.IndexOf("\")+1)
    $hiveId = 2147483650  # HKLM
    $r = $k1.EnumValues($hiveId, $key)
    Write-Output "KEY $p rc=$($r.ReturnValue)"
    if ($r.ReturnValue -eq 0) {
      for ($i=0; $i -lt $r.sNames.Count; $i++) {
        Write-Output "  $($r.sNames[$i]) = $($r.sValues[$i])"
      }
    }
  }
} catch {
  Write-Output "reg_failed: $($_.Exception.Message)"
}

Write-Output "=== T102 scripts reference (which DC was coerced) ==="
Select-String -Path "C:\Tools\cadre-attack\campaign-a-t102-*.ps1" -Pattern "TargetDC|SpoolSample" | Select-Object -First 6 | ForEach-Object { $_.Line.Trim() }
