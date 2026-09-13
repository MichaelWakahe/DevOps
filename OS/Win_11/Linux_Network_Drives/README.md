# Linux network drives on Windows 11

Use these PowerShell scripts to map Linux folders as Windows SMB network drives
only when you need them. They do not install startup tasks, save passwords, or
configure automatic mounting.

| Script | Purpose |
| --- | --- |
| `Mount-Linux.ps1` | Map `/home` to `H:` and `/tmp` to `T:` using Samba. |
| `Unmount-Linux.ps1` | Disconnect those mappings without removing unrelated shares. |

The scripts require Windows PowerShell 5.1 or PowerShell 7 on Windows 11.
The Linux laptop must be powered on, awake, and reachable to access its files.
These are remote files, not an offline copy.

## SMB or SSH?

**Choose SMB for Windows drive letters. Choose VS Code Remote - SSH for development
that needs Linux tools.** They can be used together.

| Consideration | SMB | SSH / SSHFS |
| --- | --- | --- |
| Windows drive letters | Built into Windows. | SSHFS requires extra software, typically SSHFS-Win and WinFsp. |
| PowerShell mounting | Use `net use`, as these scripts do. | Possible with an SSHFS client, but requires additional setup. |
| Explorer and Windows applications | Generally the better fit. | More filesystem compatibility quirks. |
| Network security | Use a trusted LAN or VPN; require SMB encryption if needed. | SSH encrypts traffic by default. |
| Linux builds and tools | Mapping alone does not run tools on Linux. | Remote - SSH runs development tools on Linux; SSHFS alone does not. |

For a Linux-oriented project, use VS Code Remote - SSH as the primary development
workflow and these SMB drives for browsing, copying, or opening files with Windows
applications. Remote - SSH does not create drive letters.

Tools launched locally against a mapped drive still run on Windows. Linux
executable permissions, symlinks, case sensitivity, and file watchers may not
behave as expected through Windows filesystem access. Large dependency trees and
builds can also be slow over a network share.

## 1. Set up Samba on Linux

These commands assume **Ubuntu or Debian**. Other distributions may use different
package names, service names, firewall commands, or SELinux configuration.
Replace `youruser` with your existing Linux username.

```bash
sudo apt update
sudo apt install samba
sudo smbpasswd -a youruser
```

The last command creates a Samba login for the existing Linux account and prompts
for a password. This password can differ from your Linux login password.

Edit `/etc/samba/smb.conf`, preserving the existing configuration:

```bash
sudo nano /etc/samba/smb.conf
```

Add these sections. If sections with these names already exist, update them rather
than adding duplicates:

```ini
[linux-home]
    path = /home
    read only = no
    browseable = no
    guest ok = no
    valid users = youruser
    smb encrypt = required

[linux-tmp]
    path = /tmp
    read only = no
    browseable = no
    guest ok = no
    valid users = youruser
    smb encrypt = required
```

The shares require authenticated access and SMB encryption, supported by Windows
11. Do not enable SMB1 or insecure guest logons.

Linux permissions still apply: a writable share does not grant your account
access to other users' private files. Do not use `chmod -R 777` or force Samba
operations to run as root to work around permissions.

**Limit exposure where practical.** `/home` can contain credentials and SSH keys;
consider using `/home/youruser/projects` as the `linux-home` share's path instead.
`/tmp` may contain sensitive temporary files, sockets, and other users' files.
It is not durable storage and may be cleared automatically or at reboot. A
dedicated scratch directory is safer if sharing all of `/tmp` is unnecessary.
If you change either share's path, its Windows drive letter remains the same.

Validate the configuration, then restart Samba only if validation succeeds:

```bash
sudo testparm -s && sudo systemctl restart smbd
```

## 2. Configure network access

Give the laptop a stable IP address, preferably with a DHCP reservation on your
router. Use that address or a resolvable hostname as `-LinuxHost`.

If you use the hostname setup in [Windows 11.md](../Windows%2011.md), that name can
be supplied instead of an IP address. Always use the same hostname or IP for
mounting and unmounting; the unmount script compares the saved share paths.

Allow inbound **TCP 445** on Linux only from your Windows computer or a trusted
LAN/VPN. For example, if UFW is already enabled, replace `192.168.1.50` with your
Windows computer's address:

```bash
sudo ufw allow from 192.168.1.50 to any port 445 proto tcp
```

Review any existing broader firewall rules: adding a restricted rule does not
remove rules that already allow wider access. Do not expose SMB directly to the
internet or forward port 445 on your router. Use a VPN for access outside your LAN.

You can check connectivity from Windows:

```powershell
Test-NetConnection -ComputerName 192.168.1.100 -Port 445
```

Replace the example address with the laptop's address.

## 3. Mount the drives

Open a **normal, non-administrator PowerShell window** in this directory. Drive
mappings created in an elevated session may not appear in normal Explorer or
editor sessions.

```powershell
.\Mount-Linux.ps1 -LinuxHost 192.168.1.100 -LinuxUser youruser
```

Enter the Samba password at the prompt; it is not displayed or written into the
script. The second share reuses the authenticated connection.

The default mappings are:

| Windows path | Linux path |
| --- | --- |
| `H:\youruser` | `/home/youruser` |
| `T:\` | `/tmp` |

To use different, unused drive letters:

```powershell
.\Mount-Linux.ps1 -LinuxHost 192.168.1.100 -LinuxUser youruser -HomeDrive L -TmpDrive M
```

Pass letters without colons. The scripts reject identical drive letters, and the
mount script refuses drive letters already visible to PowerShell. Windows also
rejects mappings to occupied letters.

If mapping the second share fails, the first remains mapped and the script reports
that partial result. Run the unmount script before retrying.

If local execution policy blocks scripts, and your organization's policy permits
it, enable local scripts for this PowerShell session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

This does not override organization-enforced policy. Review downloaded scripts
before unblocking them; do not disable security controls globally.

## 4. Dismount the drives

Save your work and close editors, Explorer windows, terminals, and other processes
using the drives. Change any terminal's current directory to a local path first.

```powershell
.\Unmount-Linux.ps1 -LinuxHost 192.168.1.100
```

For custom letters, supply the same values used when mounting:

```powershell
.\Unmount-Linux.ps1 -LinuxHost 192.168.1.100 -HomeDrive L -TmpDrive M
```

The script checks that each letter points to the expected share before deleting
the mapping. Already-unmapped letters are reported and skipped. An unexpected
share is left unchanged and reported as an error. It attempts both disconnections
even if one fails. It does not automatically confirm forced disconnection of open
files.

The laptop does not have to be reachable to remove a stale local mapping, although
Windows can take time to release a disconnected share.

## No automatic mounting

Each mount uses **`/persistent:no`**:

- Windows does not save these mappings for restoration at the next sign-in.
- Closing PowerShell does not disconnect the drives; mappings last for the current
  Windows sign-in session unless explicitly removed.
- Locking or sleeping Windows is not signing out. Existing mappings can still
  reconnect when the laptop becomes available.
- While a drive remains mapped, Windows or applications may try to access it even
  if the laptop is offline. Unmount before switching the laptop off.

Do not add the mount script to your PowerShell profile, Startup folder, or a
scheduled task if you want manual-only operation.

`/persistent:no` does not erase older persistent mappings. Inspect existing
connections with:

```powershell
net.exe use
```

Remove an old mapping only after confirming its letter and share, for example:

```powershell
net.exe use H: /delete
```

The unmount script can also remove an older mapping if its letter and share path
match the supplied parameters.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| Network path not found or port 445 unreachable | Check power/sleep state, hostname resolution, laptop address, Samba service, firewall, and Wi-Fi client isolation. |
| Access denied | Check the Samba username/password, `valid users`, and Linux ownership/permissions on the target files. |
| Drive letter already in use | Inspect `Get-PSDrive` and `net.exe use`; choose unused letters or deliberately remove the conflicting mapping. |
| Error 1219 / different credentials for the same server | Windows already has an SMB connection using another account. Close the relevant applications, inspect `net.exe use`, and disconnect only that server's conflicting connections before retrying. |
| Unmount refuses an unexpected share | Use the exact host/IP and drive letters used to mount. Inspect the mapping rather than deleting an unrelated drive. |
| Drives missing in Explorer | Run the scripts in the same normal Windows user context as Explorer, not an elevated terminal. |
| Disconnect reports open files | Save and close applications using the drive, change terminals to a local directory, then retry. |

Do not use `net use * /delete` as routine troubleshooting: it disconnects unrelated
network drives too.

## References

- [Microsoft: net use](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/gg651155(v=ws.11))
- [Samba: smb.conf](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html)
- [Ubuntu: Samba share access controls](https://ubuntu.com/server/docs/how-to/samba/share-access-controls/)
- [VS Code: Remote development using SSH](https://code.visualstudio.com/docs/remote/ssh)
