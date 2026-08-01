$p = 'C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Lib\site-packages\impacket\tds.py'
Select-String -Path $p -Pattern 'def connect|def login|def setLogin|class TDS|def sql_query|def getReplies|def printReplies|SQL_LOGIN|def disconnect' | ForEach-Object { $_.LineNumber.ToString() + ': ' + $_.Line.Trim() }
