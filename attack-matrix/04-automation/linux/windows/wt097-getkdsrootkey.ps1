# WT097 cross-check - enumerate KDS root keys on the DC (as DA) and print the
# key ID (cn) + first 16 bytes of RootKeyData for comparison with the LDAP read.
Get-KdsRootKey | ForEach-Object {
  $g = [BitConverter]::ToString($_.RootKeyData[0..15])
  Write-Output ("KDSKEY|cn=" + $_.cn + "|blobhead=" + $g)
}
Write-Output "CROSSCHECK_DONE"
