---
applyTo: "**/*.ps1"
---

# PowerShell conventions

**When to read:** Editing Windows automation, especially Linux network-drive scripts.

- Wrap comment-based help prose at 120 columns, not 80. Keep usage commands intact rather than wrapping them as prose.
- The network-drive scripts declare `#Requires -Version 5.1`. Keep them compatible
  with Windows PowerShell 5.1 as well as PowerShell 7 on Windows; avoid PowerShell
  7-only operators unless intentionally changing and documenting that requirement.
- Use named parameters and validation for caller-supplied values. Keep hostnames,
  usernames, and drive letters configurable rather than personalizing defaults.
- Check `$LASTEXITCODE` immediately after native commands such as `net.exe`;
  `$ErrorActionPreference` alone does not reliably handle native failures across
  supported PowerShell versions.
- Quote UNC paths and use `"${Drive}:"` when a colon follows an interpolated
  variable. Preserve drive-letter collision checks.
- Keep SMB mappings nonpersistent (`/persistent:no`). Do not add automatic
  startup tasks, saved passwords, or wildcard drive deletion.
- Prompt securely for authentication. Do not accept or log plaintext passwords
  unnecessarily, or put credentials in source files.
- Before disconnecting a drive, verify its remote share matches the requested
  target. Leave unrelated mappings unchanged; report partial mount/unmount failure.
- Do not silently swallow operational failures or force-close open files.
- Parse scripts without execution for a first check. Test live mappings only with
  an explicitly authorized host and available drive letters, using the same
  non-elevated Windows user context as Explorer.
