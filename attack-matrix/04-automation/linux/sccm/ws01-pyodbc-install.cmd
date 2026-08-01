@echo off
python -m pip install --quiet pyodbc
python -c "import pyodbc; print('pyodbc', pyodbc.version)"
