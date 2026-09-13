<#
.SYNOPSIS
Disconnects the Windows network drives mapped to Linux Samba shares.

.DESCRIPTION
Disconnects the linux-tmp and linux-home mappings, using T: and H: by default. Checks each drive's remote share before
removing it so unrelated mappings are left unchanged. Reports already-unmapped drives and attempts both disconnections
even if one fails.

.PARAMETER LinuxHost
The exact hostname or IP address supplied to Mount-Linux.ps1. Use the same spelling rather than switching between a
hostname and its IP.

.PARAMETER HomeDrive
Drive letter used for linux-home, without a colon. Defaults to H.

.PARAMETER TmpDrive
Drive letter used for linux-tmp, without a colon. Defaults to T. Must differ from HomeDrive.

.EXAMPLE
.\Unmount-Linux.ps1 -LinuxHost 192.168.1.100

Disconnects T: and H: if they point to the expected shares on 192.168.1.100. Replace the example address with the host used
when mounting.

.EXAMPLE
.\Unmount-Linux.ps1 -LinuxHost linux-laptop -HomeDrive L -TmpDrive M

Disconnects custom M: and L: mappings created with the hostname linux-laptop.

.NOTES
Run under the same non-elevated Windows user context used to mount the drives. Save work, close applications using the
drives, and change terminal directories to a local path first. The script does not automatically confirm disconnection of
open files. Unexpected shares are preserved and reported as errors. Requires Windows PowerShell 5.1 or PowerShell 7 on
Windows and Get-SmbMapping.
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$LinuxHost,

    [ValidatePattern('^[D-Zd-z]$')]
    [string]$HomeDrive = 'H',

    [ValidatePattern('^[D-Zd-z]$')]
    [string]$TmpDrive = 'T'
)

$PSNativeCommandUseErrorActionPreference = $false

if ($HomeDrive -eq $TmpDrive) {
    throw 'HomeDrive and TmpDrive must use different drive letters.'
}

$targets = @(
    @{ LocalPath = "${TmpDrive}:"; RemotePath = "\\$LinuxHost\linux-tmp" }
    @{ LocalPath = "${HomeDrive}:"; RemotePath = "\\$LinuxHost\linux-home" }
)

# Check the remote paths so unrelated mappings are never disconnected.
$mappings = @(Get-SmbMapping -ErrorAction Stop)
$failed = $false

foreach ($target in $targets) {
    $mapping = $mappings | Where-Object { $_.LocalPath -eq $target.LocalPath }
    if (-not $mapping) {
        Write-Host "$($target.LocalPath) has no SMB mapping; nothing to disconnect."
        continue
    }

    if ($mapping.RemotePath -ne $target.RemotePath) {
        Write-Error "$($target.LocalPath) points to $($mapping.RemotePath), not $($target.RemotePath). Leaving it unchanged." -ErrorAction Continue
        $failed = $true
        continue
    }

    # Do not force disconnection: net use can ask about files still in use.
    net.exe use $target.LocalPath /delete
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Could not disconnect $($target.LocalPath). See the net use error above." -ErrorAction Continue
        $failed = $true
    }
}

if ($failed) {
    throw 'Some drives could not be disconnected. Review the errors above.'
}
