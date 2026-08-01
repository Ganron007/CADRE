import inspect
from impacket.tds import MSSQL
print('init:', inspect.signature(MSSQL.__init__))
print('connect:', inspect.signature(MSSQL.connect))
print('sql_query:', inspect.signature(MSSQL.sql_query))
