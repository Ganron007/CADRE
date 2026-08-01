import inspect
from impacket.tds import MSSQL
print(inspect.signature(MSSQL.__init__))
