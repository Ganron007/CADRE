Write-Output "=== port 135 to dc01 ==="
Test-NetConnection 192.168.77.10 -Port 135 -WarningAction SilentlyContinue | Select-Object ComputerName, RemotePort, TcpTestSucceeded
Write-Output "=== port 445 to dc01 ==="
Test-NetConnection 192.168.77.10 -Port 445 -WarningAction SilentlyContinue | Select-Object ComputerName, RemotePort, TcpTestSucceeded
Write-Output "=== certipy req -h scheme options ==="
python "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe" req -h 2>&1 | Select-String -Pattern "scheme|http|rpc|target-http|target-rpc"
