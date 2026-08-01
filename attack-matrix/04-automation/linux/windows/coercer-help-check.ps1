# Check coercer coerce-mode options for listener port / WebDAV
$ErrorActionPreference = "Continue"
$env:PYTHONIOENCODING = "utf-8"
& "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce -h 2>&1 | Out-File C:\Tools\cadre-attack\coercer-coerce-help.txt -Encoding UTF8 -Force
Get-Content C:\Tools\cadre-attack\coercer-coerce-help.txt
