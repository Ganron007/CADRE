# Test SSH to linux01 (192.168.77.40) as cadre.local domain users via password auth
$ErrorActionPreference = "Continue"
$dir = "C:\STUDY\Github\CADRE-Platform\CADRE\attack-matrix\04-automation\linux\windows"
$env:SSH_ASKPASS_REQUIRE = "force"
$env:DISPLAY = "dummy"

function Test-SshUser($user, $askpass) {
  $env:SSH_ASKPASS = "$dir\$askpass"
  Write-Output "=== SSH test: $user ==="
  & ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=8 -o NumberOfPasswordPrompts=1 "$user@192.168.77.40" "whoami && id && groups" 2>&1
  Write-Output "rc=$LASTEXITCODE"
}

Test-SshUser "mssql-linux01@cadre.local" "askpass-mssql-linux01.cmd"
Test-SshUser "svc_mssql@child.cadre.local" "askpass-svc-mssql.cmd"
Write-Output "=== SSH_TEST_DONE ==="
