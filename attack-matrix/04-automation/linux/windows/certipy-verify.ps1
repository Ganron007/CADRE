Write-Output "=== certipy version ==="
python -c "import certipy; print('version', getattr(certipy, '__version__', 'n/a'))" 2>&1
Write-Output "=== entry points ==="
Get-ChildItem "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts" -Name | Select-String "certipy"
Write-Output "=== site-packages ==="
Get-ChildItem "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Lib\site-packages" -Directory -Name | Select-String "certipy"
Write-Output "=== try module exec ==="
python -m certipy_ad find -h 2>&1 | Select-Object -First 3
