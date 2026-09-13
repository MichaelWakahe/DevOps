---
applyTo: "IaC/Ansible/**,Desktop Virtualization/Vagrant/**,Desktop Virtualization/Docker/**"
---

# Infrastructure example conventions

**When to read:** Editing Ansible, Vagrant, Dockerfiles, or Compose examples.

## Ansible

- Follow the role's existing `defaults`, `vars`, `tasks`, `handlers`, and
  `templates` organization. Keep Jinja templates and their variable definitions
  consistent with callers.
- Prefer idempotent modules and existing notification/handler patterns over
  unconditional shell commands or service restarts.
- Preserve role variable names, tags, OS-family conditions, and dependency order.
  Inspect `site.yml` and the calling Vagrantfile before changing role interfaces.
- These examples include legacy Ansible syntax and upstream-derived roles.
  Do not mass-convert module names, loops, includes, or Molecule configuration
  without an explicit compatibility/migration task.
- Localhost playbooks can change real databases or cloud resources; `hosts:
  localhost` is not evidence that execution is safe.
- Inspect inventories, lookups, role requirements, and secret sources before
  syntax checks. Use disposable, authorized targets for integration tests.
- Preserve role-local tests and attribution. Do not assume old `.travis.yml` or
  Molecule files run in root CI or work with the latest tool versions.

## Docker and Vagrant

- Keep image versions and Vagrant box/provider choices explicit. Version upgrades
  must be intentional; do not replace pinned versions with `latest` as cleanup.
- Review host port bindings, bind mounts, bridge interfaces, subnets, and guest
  paths together. Prefer loopback bindings for new local-only services.
- Keep Vagrant provisioning tags aligned with the Ansible role tags they select.
- Do not start VMs, pull images, build containers, create networks, or run
  privileged containers just to validate formatting or syntax.
- Prefer Compose `config --quiet` to avoid printing resolved environment values.
  It validates configuration, not image compatibility or running services.
- A Vagrantfile is executable Ruby. `ruby -c` checks syntax without evaluating it;
  commands that load the Vagrantfile require reviewing its code and plugins first.
