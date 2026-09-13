---
applyTo: "**/*.md"
---

# Documentation conventions

**When to read:** Writing or updating setup guides, configuration notes, or READMEs.

- Wrap prose at 120 columns, not 80, including AI directives. Do not split commands, URLs, or tables just to fit.
- Keep instructions next to their example; do not assume a root application or
  shared installation procedure.
- Identify the target OS/distribution, required tools, working directory, and
  whether each command runs on the Windows host, Linux laptop, VM, or container.
- Label code fences with their actual language, such as `powershell`, `bash`,
  `yaml`, or `ini`. Quote paths with spaces using that shell's syntax.
- Separate one-time setup, routine use, and cleanup. Explain elevated privileges,
  persistence across sign-in/reboot, and destructive or network-exposing effects.
- Keep parameter names, default drive letters, share names, and error behavior in
  sync with companion scripts. Distinguish remote file access from remote execution.
- Use clearly identified placeholders for usernames, addresses, paths, and secrets.
  Do not copy personal values from older examples into new documentation.
- Use relative links for repository files, with URL-style slashes and encoded
  spaces. Use official documentation for external references where possible.
- Treat outdated version claims and boilerplate sections as unverified. Do not
  describe legacy examples as current production recommendations.
- Do not run installation, firewall, database, or provisioning commands merely
  because they appear in a tutorial.
