$ErrorActionPreference = 'SilentlyContinue'
if ([System.Environment]::OSVersion.Version.Major -eq 10 -or [System.Environment]::OSVersion.Version.Major -eq 6 ) {Get-AppxPackage | Remove-AppxPackage}
