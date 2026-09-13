# AI contributor configuration

These files provide repository-specific guidance for GitHub Copilot and other
agents that support `AGENTS.md`. They do not install tools, enable cloud agents,
change permissions, run workflows, or provision infrastructure.

## Files and scope

| File | Purpose |
| --- | --- |
| [AGENTS.md](../AGENTS.md) | Shared editing, operational safety, and validation rules for agents. |
| [copilot-instructions.md](copilot-instructions.md) | Short repository-wide Copilot entry point and essential context. |
| [documentation.instructions.md](instructions/documentation.instructions.md) | Markdown guides and README conventions. |
| [powershell.instructions.md](instructions/powershell.instructions.md) | PowerShell compatibility, error handling, and safe drive mapping. |
| [infrastructure.instructions.md](instructions/infrastructure.instructions.md) | Ansible roles and Docker/Vagrant examples. |

Copilot clients that support path-specific instructions use the `applyTo` globs in
each file's YAML frontmatter. Multiple matching files can apply together: an
Ansible README receives both documentation and infrastructure guidance.

Feature support varies by Copilot client. The root `AGENTS.md` points agents to
the scoped files for clients that do not automatically load them. Keep essential
rules in the root baseline and the Copilot entry point; do not assume a link alone
loads its target in every client.

These are guidance, not an enforced security boundary. Human review and tool
permissions still control whether operational actions are allowed.

## Using the guidance

Open the repository root in your editor and use Copilot with repository custom
instructions enabled. In clients that show instruction references, inspect them
to confirm which files are in context. Other environments need access to the
branch containing these files; local changes alone do not update GitHub.

Give tasks a concrete scope and target environment, for example:

> Update the network-drive guide for a Debian laptop without changing the
> nonpersistent mapping behavior. Do not connect to a live host.

No global setup or verification script is provided because the examples use
different tools and some provisioning operations have real side effects.
No Copilot setup workflow, automatic hooks, or additional agent personas are
needed for the baseline configuration.

## Non-deploying validation examples

Run only checks relevant to the files being changed. The commands below are
examples, not a complete test suite. Docker and Ruby checks require those tools
to be installed; they are not dependencies for editing Markdown.

From the repository root, parse a PowerShell script **without running it**:

```powershell
$path = (Resolve-Path '.\OS\Win_11\Linux_Network_Drives\Mount-Linux.ps1').Path
$tokens = $null
$parseErrors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile(
    $path, [ref]$tokens, [ref]$parseErrors
)
if ($parseErrors.Count -gt 0) {
    throw ($parseErrors | Out-String)
}
```

Substitute the changed script's path. Parsing does not check native command
behavior, Windows PowerShell 5.1 compatibility when run under PowerShell 7, or
connectivity to a real Samba server.

Validate the existing Compose example without starting containers:

```powershell
docker compose -f '.\Desktop Virtualization\Docker\Elastic\docker-compose.yml' config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Compose configuration validation failed.' }
```

Check Vagrantfile Ruby syntax without evaluating its provisioning configuration:

```powershell
ruby -c '.\Desktop Virtualization\Vagrant\GenericVirtualMachine\Vagrantfile'
if ($LASTEXITCODE -ne 0) { throw 'Vagrantfile Ruby syntax check failed.' }
```

For Ansible, first inspect the changed playbook, included roles, and local test
configuration. Syntax checks require a compatible Ansible installation and may
need inventory or variables. Do not substitute a real deployment for a missing
test environment, or run role-local privileged Molecule scenarios without approval.

For Markdown-only changes, check relative links, shell syntax, prerequisites, and
agreement with companion code; no application build is required.

## Maintaining instructions

Keep shared rules in `AGENTS.md`, the Copilot entry point short, and domain details
in the scoped files. Update globs when moving examples. Do not add empty
instruction files, speculative build commands, or duplicate every rule across
multiple files.

See [GitHub's repository instructions documentation](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions)
for supported formats and client-specific behavior.
