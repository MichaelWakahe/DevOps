# WezTerm configuration

[wezterm.lua](wezterm.lua) contains the shared WezTerm configuration, including platform-specific settings for Windows,
macOS, and Linux. It was moved here from `OS/Linux/home/dot_config/wezterm/wezterm.lua`.

## Choosing the active configuration

The file in this repository is a source copy, not automatically your active configuration. On each computer, copy or
merge [wezterm.lua](wezterm.lua) into **one** of the locations listed for its operating system below. Create the parent
directory if it does not exist, and preserve or back up existing settings before replacing anything.

The filename matters: use `wezterm.lua` inside a `wezterm` configuration directory, or `.wezterm.lua` directly in your
home directory. `userprofile` in the examples is a placeholder for your actual account directory.

WezTerm checks explicit `--config-file` and `WEZTERM_CONFIG_FILE` overrides before its normal locations. A configuration
beside `wezterm.exe` on Windows also takes precedence over the normal user locations. Otherwise, it checks
`$XDG_CONFIG_HOME/wezterm/wezterm.lua` when that variable is set, then `~/.config/wezterm/wezterm.lua`, then
`~/.wezterm.lua`. These files are alternatives, not configurations that are automatically merged.

Save the configuration on the computer **running WezTerm**, not on a Linux machine merely accessed through SSH.
WezTerm normally reloads it automatically; Ctrl+Shift+R forces a reload.

## Windows

### Configuration file locations

| Location | Example |
| --- | --- |
| `%USERPROFILE%\.config\wezterm\wezterm.lua` | `C:\Users\userprofile\.config\wezterm\wezterm.lua` |
| `%USERPROFILE%\.wezterm.lua` | `C:\Users\userprofile\.wezterm.lua` |
| `%XDG_CONFIG_HOME%\wezterm\wezterm.lua`, if `XDG_CONFIG_HOME` is set | A custom configuration root followed by `\wezterm\wezterm.lua`. |

The `%VARIABLE%` notation describes Windows environment-variable paths, usable in Explorer's address bar. In
PowerShell, refer to them as `$env:USERPROFILE` or `$env:XDG_CONFIG_HOME`.

For portable installations, WezTerm also supports `wezterm.lua` beside `wezterm.exe`. For an ordinary installation, use
a per-user location above instead.

### Keep Git Bash as the default

Copy or merge the repository configuration into your chosen Windows location above. Do not create a second config file
if WezTerm already loads one from another location.

The Windows branch starts Git Bash for new local tabs and splits that use the default program:

```lua
config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '--login', '-i' }
config.allow_win32_input_mode = true
```

This assumes Git for Windows is installed at the shown path. Adjust it in your active configuration if necessary.
Reload WezTerm and open a new tab; existing tabs retain their running shell. Neither PowerShell nor Agency starts
automatically. Explicitly selected programs and remote domains can override the default program.

### Launch Agency through PowerShell only when needed

From **Git Bash on Windows**, change to the project directory where you want to work, then run:

```bash
pwsh.exe -NoLogo -NoExit -Command 'agency copilot'
```

This starts PowerShell 7 in the current tab, loads its normal profile, and runs `agency copilot`. It does not change
WezTerm's default shell or affect other tabs. Typing plain `agency copilot` in Git Bash still launches it directly from
Bash; this configuration does not intercept or wrap that command.

PowerShell 7 must be installed with `pwsh.exe` on PATH, and `agency` must be available from PowerShell. A Git Bash alias
or function alone is not sufficient. `-NoExit` keeps PowerShell open after Copilot exits or if Agency fails to launch,
so you can see errors and correct the setup.

After leaving Copilot, type `exit` at the PowerShell prompt to return to the original Git Bash session. To return to
Git Bash immediately when Copilot finishes instead, omit `-NoExit`:

```bash
pwsh.exe -NoLogo -Command 'agency copilot'
```

With the `-NoExit` variant, you can confirm the shell and command availability after exiting Copilot:

```powershell
$PSVersionTable
Get-Command agency
```

`PSVersion` should start with `7` and `PSEdition` should be `Core`. This targeted launcher needs no profile changes or
Windows startup tasks.

### Multiline input: Copilot versus the PowerShell prompt

**These are separate input editors.** PSReadLine bindings affect the PowerShell prompt, not the interactive Copilot
prompt. Starting Copilot from PowerShell does not make Copilot use PSReadLine.

The earlier Shift+Enter-to-Ctrl+O workaround has been removed from the shared config: Copilot uses Ctrl+O to toggle its
timeline, not insert a newline. If you merged this config with an older copy, remove that old Shift+Enter entry from
`config.keys`. The Windows configuration permits native Win32 keyboard input instead.

At the Copilot prompt, use Shift+Enter for a newline. If it still submits instead, run `/terminal-setup` inside Copilot
and follow its terminal-specific guidance. Review any proposed active configuration changes before applying them.

### Optional PowerShell prompt bindings

After exiting Copilot, run this at the PowerShell 7 prompt to explicitly bind Shift+Enter to multiline editing:

```powershell
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Chord 'Shift+Enter' -Function AddLine
```

For a fallback shortcut at the PowerShell prompt only, you can also bind Ctrl+O:

```powershell
Set-PSReadLineKeyHandler -Chord 'Ctrl+o' -Function AddLine
```

Do not map Shift+Enter to Ctrl+O in WezTerm to support this fallback; that would also affect Copilot and other programs.

In PowerShell 7 on Windows, create the current user's profile if necessary, then open it in Notepad:

```powershell
if (-not (Test-Path -LiteralPath $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
notepad.exe $PROFILE
```

Add your chosen bindings after any existing PSReadLine imports, editing-mode selection, or key-binding configuration:

```powershell
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Chord 'Shift+Enter' -Function AddLine
```

Save the profile and start a new PowerShell 7 session to load it. These steps configure the shell, not Agency's editor.

`$PROFILE` identifies the current user's profile for the current PowerShell host. Editing it from PowerShell 7 avoids
accidentally editing the separate Windows PowerShell 5.1 profile. A session started with `-NoProfile` will not load the
binding. If an organization-enforced execution policy blocks profiles, follow that policy rather than bypassing it.

To undo optional shell bindings, remove or restore their lines in your PowerShell profile and start a new session.

## Linux

### Configuration file locations

| Location | Example |
| --- | --- |
| `~/.config/wezterm/wezterm.lua` | `/home/userprofile/.config/wezterm/wezterm.lua` |
| `~/.wezterm.lua` | `/home/userprofile/.wezterm.lua` |
| `$XDG_CONFIG_HOME/wezterm/wezterm.lua`, if `XDG_CONFIG_HOME` is set | With `XDG_CONFIG_HOME=/home/userprofile/config`, use `/home/userprofile/config/wezterm/wezterm.lua`. |

`~` expands to your home directory, which is commonly `/home/yourusername` but may be configured elsewhere. For your
example directory `/home/userprofile/.config/wezterm`, the full filename is
`/home/userprofile/.config/wezterm/wezterm.lua`.

### Activate the configuration

For the common `~/.config/wezterm/wezterm.lua` location, create its parent directory from a Linux shell:

```bash
mkdir -p "$HOME/.config/wezterm"
```

Save or merge the repository's `wezterm.lua` into that directory. If `XDG_CONFIG_HOME` is set and already contains a
WezTerm configuration, update that file instead. Keep only the intended active configuration and reload WezTerm.

### Shell and keyboard behavior

The Windows PowerShell profile instructions above do not configure Bash, Zsh, or other Linux shells. This configuration
does not change the Linux default shell or start Agency automatically on Linux. Shift+Enter is passed through rather
than mapped to Ctrl+O; its behavior depends on the receiving application and keyboard protocol.

## macOS

### Configuration file locations

| Location | Example |
| --- | --- |
| `~/.config/wezterm/wezterm.lua` | `/Users/userprofile/.config/wezterm/wezterm.lua` |
| `~/.wezterm.lua` | `/Users/userprofile/.wezterm.lua` |
| `$XDG_CONFIG_HOME/wezterm/wezterm.lua`, if `XDG_CONFIG_HOME` is set | A custom configuration root followed by `/wezterm/wezterm.lua`. |

`~` expands to your home directory, commonly `/Users/yourusername`. Use one of these locations rather than assuming the
file belongs in `~/Library/Application Support`.

### Activate the configuration

For the common `~/.config/wezterm/wezterm.lua` location, create its parent directory from a macOS shell:

```bash
mkdir -p "$HOME/.config/wezterm"
```

Save or merge the repository's `wezterm.lua` into that directory, or update your existing configuration in another
supported location. Reload WezTerm after saving.

### Shell and keyboard behavior

The Windows PowerShell profile steps do not apply to the default macOS shell. This configuration does not change the
macOS default shell or start Agency automatically on macOS. Shift+Enter is not remapped to Ctrl+O and does not
automatically add multiline editing to Zsh or Bash.

## References

- [WezTerm configuration locations](https://wezterm.org/config/files.html)
- [WezTerm SendKey action](https://wezterm.org/config/lua/keyassignment/SendKey.html)
- [WezTerm default program](https://wezterm.org/config/lua/config/default_prog.html)
- [WezTerm Win32 input mode](https://wezterm.org/config/lua/config/allow_win32_input_mode.html)
- [PSReadLine AddLine function](https://learn.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline_functions#addline)
- [PowerShell profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)
