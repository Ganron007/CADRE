[CmdletBinding()]
param(
    [string]$Account,
    [string]$Password,
    [string]$ScriptPath,
    [string]$ArgsFile = 'C:\Users\Public\cadre-ws01-exec-args.json'
)
$ErrorActionPreference = 'Continue'
if (Test-Path $ArgsFile) {
    $a = Get-Content $ArgsFile -Raw | ConvertFrom-Json
    if (-not $Account) { $Account = [string]$a.Account }
    if (-not $Password) { $Password = [string]$a.Password }
    if (-not $ScriptPath) { $ScriptPath = [string]$a.ScriptPath }
}
$Account = $Account.Trim().Trim("'").Trim('"')
$ScriptPath = $ScriptPath.Trim().Trim("'").Trim('"')
if (-not $Account -or -not $Password -or -not $ScriptPath) {
    throw 'ws01-exec-hop: Account, Password, and ScriptPath are required'
}
$task = 'CADRE-ws01-exec'
$out = 'C:\Users\Public\cadre-ws01-exec.out'
$rcf = 'C:\Users\Public\cadre-ws01-exec.rc'
$runner = 'C:\Users\Public\cadre-ws01-exec-runner.ps1'
$cfg = 'C:\Users\Public\cadre-secedit.cfg'
$db = 'C:\Windows\Temp\cadre-secedit.sdb'
Write-Output ("ws01-exec: hop user=" + $Account + " via scheduled task")

secedit /export /cfg $cfg | Out-Null
$raw = Get-Content $cfg
$line = $raw | Where-Object { $_ -like 'SeBatchLogonRight*' } | Select-Object -First 1
if ($line -and $line -notmatch [regex]::Escape($Account)) {
    $new = if ($line -match '=\s*$') { "$line $Account" } else { "$line,$Account" }
    $raw = $raw | ForEach-Object { if ($_ -like 'SeBatchLogonRight*') { $new } else { $_ } }
    $raw | Set-Content $cfg -Encoding ASCII
    secedit /configure /db $db /cfg $cfg /areas USER_RIGHTS | Out-Null
}

@"
`$ErrorActionPreference = 'Continue'
& powershell -NoProfile -ExecutionPolicy Bypass -File '$ScriptPath' *>&1 | Out-File -FilePath '$out' -Encoding utf8
if (`$null -ne `$LASTEXITCODE) { Set-Content -Path '$rcf' -Value `$LASTEXITCODE } else { Set-Content -Path '$rcf' -Value 0 }
"@ | Set-Content -Path $runner -Encoding ASCII

Remove-Item $out, $rcf -Force -ErrorAction SilentlyContinue
schtasks /Delete /TN $task /F 2>&1 | Out-Null
$tr = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner"
$create = schtasks /Create /TN $task /TR $tr /RU $Account /RP $Password /SC ONCE /ST 23:59 /RL LIMITED /F 2>&1
if ($LASTEXITCODE -ne 0) { throw "schtasks create failed: $create" }
$run = schtasks /Run /TN $task 2>&1
if ($LASTEXITCODE -ne 0) { throw "schtasks run failed: $run" }
$deadline = (Get-Date).AddSeconds(90)
do {
    Start-Sleep -Milliseconds 400
    $q = schtasks /Query /TN $task /FO LIST /V 2>&1 | Out-String
} while ((Get-Date) -lt $deadline -and $q -match 'Status:\s+Running')
if (-not (Test-Path $out)) { throw "hop produced no output file. query=$q" }
Get-Content $out -Raw
$code = 0
if (Test-Path $rcf) { $code = [int]((Get-Content $rcf -Raw).Trim()) }
schtasks /Delete /TN $task /F 2>&1 | Out-Null
Remove-Item $runner, $ArgsFile -Force -ErrorAction SilentlyContinue
exit $code
