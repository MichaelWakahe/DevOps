# Linux Home Configuration

These files are example home-directory configuration for Ubuntu and similar GNU/Linux systems. The repository uses a
`dot_` prefix so that the files are visible and inactive here; remove that prefix when installing them.

Review and adapt the files before installation. They replace files with the same names rather than merging with
distribution-provided or existing configuration.

## File mapping

| Repository file | Home-directory destination | Purpose |
| --- | --- | --- |
| `dot_shell_env` | `~/.shell_env` | Shared, repeatable environment and `PATH` configuration |
| `dot_profile` | `~/.profile` | Login and graphical-session environment |
| `dot_bash_profile` | `~/.bash_profile` | Bash login-shell entry point |
| `dot_bashrc` | `~/.bashrc` | Interactive Bash fallback |
| `dot_zprofile` | `~/.zprofile` | Zsh login-shell entry point |
| `dot_zshrc` | `~/.zshrc` | Interactive Zsh and optional Oh My Zsh configuration |
| `dot_inputrc` | `~/.inputrc` | GNU Readline settings used by Bash and other Readline applications |
| `dot_gitconfig` | `~/.gitconfig` | Shell-independent Git defaults |
| `dot_vimrc` | `~/.vimrc` | Shell-independent Vim defaults |
| `dot_aws/config` | `~/.aws/config` | Non-secret AWS CLI defaults |

## Install safely

Back up every existing destination before copying a file. For example:

```bash
backup_dir="$HOME/home-config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -m 700 "$backup_dir"
cp -a "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zprofile" "$HOME/.zshrc" \
    "$HOME/.inputrc" "$HOME/.gitconfig" "$HOME/.vimrc" "$backup_dir/" 2>/dev/null || true
```

From this directory, install only the files that you have reviewed. If you also want Oh My Zsh, install it before the
`dot_zshrc` copy below, or restore that copy afterward. See [Bash, Zsh, and Oh My Zsh](#bash-zsh-and-oh-my-zsh).

```bash
install -m 0644 dot_shell_env "$HOME/.shell_env"
install -m 0644 dot_profile "$HOME/.profile"
install -m 0644 dot_bash_profile "$HOME/.bash_profile"
install -m 0644 dot_bashrc "$HOME/.bashrc"
install -m 0644 dot_zprofile "$HOME/.zprofile"
install -m 0644 dot_zshrc "$HOME/.zshrc"
install -m 0644 dot_inputrc "$HOME/.inputrc"
install -m 0644 dot_gitconfig "$HOME/.gitconfig"
install -m 0644 dot_vimrc "$HOME/.vimrc"

install -d -m 0700 "$HOME/.aws"
install -m 0600 dot_aws/config "$HOME/.aws/config"
```

Open a new login session after changing profile files. Reload only an interactive-shell file with `source ~/.bashrc` or
`source ~/.zshrc`.

## Bash, Zsh, and Oh My Zsh

Bash remains a useful fallback for Ubuntu and for scripts written specifically for Bash. Zsh does not read
`.bash_profile` or `.bashrc`, so shared environment settings live in `.shell_env` and are loaded by both shells.
`.inputrc` remains useful for Bash and other Readline programs; `.zshrc` provides equivalent history-prefix navigation
and case-insensitive completion for Zsh.

[Oh My Zsh](https://ohmyz.sh/) is optional. It adds themes, a Git-aware prompt, completion, aliases, and plugins. The
supplied `.zshrc` enables its `git` and `history-substring-search` plugins when `~/.oh-my-zsh/oh-my-zsh.sh` is present.
Without it, the file uses native Zsh completion, history search, and a simple prompt.

Install Oh My Zsh before copying `dot_zshrc` to `~/.zshrc`. The official installer replaces an existing `~/.zshrc` with
its template unless you decline the prompt or pass `--keep-zshrc`. An unattended run overwrites without asking. It
keeps the previous file as `~/.zshrc.pre-oh-my-zsh`. Copy this repository's `dot_zshrc` afterward so `.shell_env` and
the plugin settings above are what load Oh My Zsh. If you install Oh My Zsh later, decline the overwrite, pass
`--keep-zshrc`, or copy `dot_zshrc` again.

On Ubuntu, install the prerequisites before following the official Oh My Zsh installation instructions:

```bash
sudo apt update
sudo apt install zsh git curl
```

Review remote installation scripts before running them. Decline the installer's login-shell prompt if you want to use
the `chsh` step below instead. After installing Zsh, make it the login shell only if desired:

```bash
chsh -s "$(command -v zsh)"
```

Log out and back in for the login-shell change to take effect.

## Development paths

`.shell_env` preserves the original Java, Maven, Gradle, Android, WildFly, Tomcat, Scala, SBT, Node.js, Go, .NET, SQL
Server, and Docker paths. They are guarded so missing directories do not pollute `PATH`, and repeated sourcing does not
duplicate entries. Several paths identify legacy versions and are examples of the original workstation layout, not
recommendations for new installations. Update them to match software that is actually installed.

## Git identity and credentials

Personal Git identity is intentionally excluded from `dot_gitconfig`. Store it in the included local file:

```bash
git config --file "$HOME/.gitconfig.local" user.name "Your Name"
git config --file "$HOME/.gitconfig.local" user.email "you@example.com"
chmod 600 "$HOME/.gitconfig.local"
```

The shared Git configuration caches HTTPS credentials in memory for 24 hours. Reduce the timeout or use a supported
credential manager if that retention period is unsuitable.

AWS credentials must never be committed to this repository. Prefer AWS IAM Identity Center:

```bash
aws configure sso
```

If static credentials are unavoidable, create them with `aws configure`, keep `~/.aws` at mode `0700`, keep
`~/.aws/credentials` at mode `0600`, and rotate any credential that is accidentally exposed.