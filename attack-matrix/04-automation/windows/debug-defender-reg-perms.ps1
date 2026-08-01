$ErrorActionPreference = 'Continue'

$paths = @(
  'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features',
  'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender',
  'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection',
  'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet'
)

foreach ($p in $paths) {
  try {
    if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null; Write-Output "CREATED $p" } else { Write-Output "EXISTS $p" }
    # attempt write
    $test = Join-Path $p "__test_write"
    try {
      New-ItemProperty -Path $p -Name '__test_write' -Value 1 -PropertyType DWord -Force -ErrorAction Stop
      Remove-ItemProperty -Path $p -Name '__test_write' -Force -ErrorAction SilentlyContinue
      Write-Output "WRITABLE $p"
    } catch {
      Write-Output "WRITE_DENIED $p : $($_.Exception.Message)"
    }
  } catch {
    Write-Output "PATH_ERR $p : $($_.Exception.Message)"
  }
}

Write-Output '--- MpPreference test ---'
try {
  Set-MpPreference -MAPSReporting 0 -ErrorAction Stop
  Write-Output 'MPPREF_OK'
} catch {
  Write-Output "MPPREF_DENIED $($_.Exception.Message)"
}
