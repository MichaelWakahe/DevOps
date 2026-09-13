# Agent instructions

## Working assumptions

- This repository contains independent DevOps examples and machine configuration, not one deployable application. Work
  within the requested example.
- Read the nearest README and actual configuration before changing behavior. Some older READMEs contain template text;
  do not infer frameworks or working commands from those placeholders.
- There is no repository-wide build, dependency installation, or test command. Do not invent one or provision all
  examples to validate a small change.
- Some Vagrant roles have their own Molecule, Ansible test playbooks, and legacy Travis configuration. These are local
  to those roles, not root CI.

## Editing conventions

- Preserve unrelated changes, including untracked files. Do not commit or push unless requested.
- Quote paths containing spaces, especially paths under `Desktop Virtualization`. Use syntax for the shell that will
  run the command: PowerShell on Windows, Bash/POSIX shell on Linux. Do not mechanically translate Linux target paths.
- Keep existing directory names and colocate usage documentation with scripts.
- Wrap Markdown prose, AI directives, and PowerShell comment-based help at 120 columns, not 80. Preserve paragraph and
  list structure; do not split commands, code, URLs, or Markdown tables solely to meet the prose width.
- Preserve compatibility with the target example. Old image versions, Ansible syntax, and OS-specific branches are not
  permission for a bulk modernization.
- Many Vagrant roles are adapted from upstream projects. Read their local documentation and preserve license notices,
  attribution, and variable names.

## Operational safety

- Treat OS configuration files as examples, not files to install on this machine. Do not copy them into live system
  directories during ordinary validation.
- Do not run cloud provisioning, database-changing playbooks, `vagrant up`, `vagrant provision`, or container startup as
  a routine check. Obtain explicit authorization for the target and side effects before operational execution.
- Ansible `--check` is not a security sandbox; plugins, lookups, and tasks can still have side effects. Inspect the
  execution path before running it.
- Do not change host networking, firewall rules, services, drive mappings, or startup behavior just to check a script
  or document.
- Never copy real credentials, private keys, account identifiers, or personal machine settings into examples, logs,
  or generated instructions. Use explicit placeholders and secure prompts or external secret sources.
- Do not reproduce insecure legacy defaults in new examples. Do not weaken authentication, enable SMB1, or grant broad
  permissions to bypass a failure.

## Validation and handoff

- Choose the smallest non-deploying check appropriate to the changed file. PowerShell scripts can be parsed without
  execution; Docker Compose offers `config --quiet`. Inspect configuration before invoking tools that evaluate it.
- Existing role tests may require Linux, Docker, privileged containers, and legacy dependencies. Check the role's
  documented prerequisites first.
- Use existing tools and tests; do not install a new validation framework or automatically download roles, images, or
  VM boxes for an unrelated edit.
- For Markdown, review commands, prerequisites, relative links, and consistency with the companion scripts. Do not
  execute privileged tutorial commands.
- Distinguish syntax checks from live integration results; report any unverified behavior when it matters to the
  requested outcome.
- Read the matching files in `.github/instructions/` for scoped conventions. See `.github/README.md` for their scope
  and non-deploying check examples.
