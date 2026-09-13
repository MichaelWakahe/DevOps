<#
.SYNOPSIS
Maps Linux Samba shares to nonpersistent Windows network drives.

.DESCRIPTION
Maps the linux-home and linux-tmp shares to H: and T: by default. Prompts for the Samba password and reuses that connection
for the second share. Mappings remain available after PowerShell closes but are not restored at the next Windows sign-in.

.PARAMETER LinuxHost
Hostname or IP address of the Linux computer running Samba.

.PARAMETER LinuxUser
Existing Samba username used to authenticate to both shares.

.PARAMETER HomeDrive
Unused drive letter for linux-home, without a colon. Defaults to H.

.PARAMETER TmpDrive
Unused drive letter for linux-tmp, without a colon. Defaults to T. Must differ from HomeDrive.

.EXAMPLE
.\Mount-Linux.ps1 -LinuxHost 192.168.1.100 -LinuxUser youruser

Maps linux-home to H: and linux-tmp to T:, prompting for the Samba password. Replace the example address and username with
your own values.

.EXAMPLE
.\Mount-Linux.ps1 -LinuxHost linux-laptop -LinuxUser youruser -HomeDrive L -TmpDrive M

Maps the shares on the resolvable hostname linux-laptop to L: and M:.

.NOTES
Run in a non-administrator PowerShell window under the same user as Explorer. Requires Windows PowerShell 5.1 or PowerShell
7 on Windows and reachable Samba shares named linux-home and linux-tmp. See README.md for Linux-side setup. If the second
mapping fails, the first remains mapped. Use Unmount-Linux.ps1 with the same host and drive letters to disconnect it before
retrying.
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$LinuxHost,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$LinuxUser,

    [ValidatePattern('^[D-Zd-z]$')]
    [string]$HomeDrive = 'H',

    [ValidatePattern('^[D-Zd-z]$')]
    [string]$TmpDrive = 'T'
)

$PSNativeCommandUseErrorActionPreference = $false

if ($HomeDrive -eq $TmpDrive) {
    throw 'HomeDrive and TmpDrive must use different drive letters.'
}

foreach ($drive in @($HomeDrive, $TmpDrive)) {
    if (Get-PSDrive -Name $drive -ErrorAction SilentlyContinue) {
        throw "Drive ${drive}: is already in use. Choose another letter or unmount it first."
    }
}

# Prompt securely, then reuse this authenticated SMB connection for the second share.
net.exe use "${HomeDrive}:" "\\$LinuxHost\linux-home" '*' "/user:$LinuxUser" /persistent:no
if ($LASTEXITCODE -ne 0) {
    throw "Could not map ${HomeDrive}:. See the net use error above."
}

net.exe use "${TmpDrive}:" "\\$LinuxHost\linux-tmp" /persistent:no
if ($LASTEXITCODE -ne 0) {
    throw "Could not map ${TmpDrive}:. ${HomeDrive}: is still mapped; run Unmount-Linux.ps1 to disconnect it."
}

Write-Host "Mapped ${HomeDrive}: to /home and ${TmpDrive}: to /tmp on $LinuxHost for this sign-in session."
