$ErrorActionPreference = 'Continue'
$python = $null
$candidates = @('python','python3','py')
foreach ($name in $candidates) {
    $python = Get-Command $name -ErrorAction SilentlyContinue
    if ($python) { break }
}
Write-Output "PYTHON_CMD=$($python.Source)"
& $python.Source --version 2>&1 | ForEach-Object { Write-Output "PYTHON_VER=$_" }
& $python.Source -m pip --version 2>&1 | ForEach-Object { Write-Output "PIP_VER=$_" }
Write-Output 'DNS_START'
try { Resolve-DnsName pypi.org -Type A 2>&1 | Select-Object -First 5 | ForEach-Object { Write-Output "DNS=$_" } } catch { Write-Output "DNS_ERR=$($_.Exception.Message)" }
Write-Output 'DNS_END'
Write-Output 'PYPI_START'
try { $r = Invoke-WebRequest -Uri 'https://pypi.org' -UseBasicParsing -TimeoutSec 20; Write-Output "PYPI_STATUS=$($r.StatusCode)" } catch { Write-Output "PYPI_ERR=$($_.Exception.Message)" }
Write-Output 'PYPI_END'
Write-Output 'SEARCH_START'
try { & $python.Source -m pip install --dry-run --no-deps NetExec 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "SEARCH=$_" } } catch { Write-Output "SEARCH_ERR=$($_.Exception.Message)" }
Write-Output 'SEARCH_END'
Write-Output 'TRY1_START'
try { & $python.Source -m pip install --no-cache-dir NetExec 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "TRY1=$_" } } catch { Write-Output "TRY1_ERR=$($_.Exception.Message)" }
Write-Output 'TRY1_END'
Write-Output 'TRY2_START'
try { & $python.Source -m pip install --no-cache-dir netexec 2>&1 | Select-Object -First 20 | ForEach-Object { Write-Output "TRY2=$_" } } catch { Write-Output "TRY2_ERR=$($_.Exception.Message)" }
Write-Output 'TRY2_END'
Write-Output '---DIAG_END---'
