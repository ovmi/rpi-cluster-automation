# Ansible Cluster Automation

This repository contains an Ansible-based automation framework for managing a cluster of Raspberry Pi nodes.

## Ansible Cluster Automation

Automation framework for managing a Raspberry Pi cluster using Ansible roles and playbooks.

This repo collects reusable Ansible roles and playbooks to bootstrap, configure and operate a small cluster (k3s, Docker, monitoring, glusterfs, PXE, NVMe provisioning and more).

## Quick overview

- Project root: repository contains top-level `playbooks/`, `roles/`, and `inventories/`.
- Work is intended to be run from a control machine with SSH access to target Raspberry Pis.

## Requirements

- A Linux/macOS control machine (x86 recommended) with network access to the nodes.
- Python 3.11+ and Ansible (tested with Ansible 2.10+ / 7.x). Install `ansible-lint` for CI checks.
- SSH key-based access to each node (default user: `pi`) or configure a different user in inventory/group_vars.

## Project layout

```
playbooks/                  # Top-level playbooks (examples below)
roles/                      # Reusable roles: k3s_install, docker_install, etc.
inventories/                # Inventory files and group_vars/host_vars/
Makefile                    # Convenience targets (run, lint, ping)
README.md
```

## Quick start

1. Ensure your control machine has Ansible and access to the target nodes.
2. Edit your inventory at `inventories/production/hosts` and variables under `inventories/production/group_vars/`.
3. Run a playbook using the `Makefile` or `ansible-playbook` directly.

Run default Makefile target (note: `Makefile` uses `PLAYBOOK` and `INVENTORY` variables):

```bash
# runs the configured playbook with the configured inventory
make run

# override to run a specific playbook
make run PLAYBOOK=playbooks/k3s_install.yml

# run ansible-lint against the configured playbook
make lint

# ping all hosts in the inventory
make ping
```

You can also call ansible-playbook directly:

```bash
ansible-playbook -i inventories/production/hosts playbooks/k3s_install.yml
```

## Available playbooks

The `playbooks/` directory contains the most common automation entry points. Examples included in this repository:

- `k3s_install.yml` — install k3s and join nodes
- `k3s_uninstall.yml` — remove k3s cluster
- `docker_install.yml` / `docker_uninstall.yml` — manage Docker
- `monitoring_install.yml` / `system_monitoring.yml` / `cpu_temp_monitor.yml` — monitoring stack and exporters
- `glusterfs_install.yml` — glusterfs setup
- `pxe_boot.yml` — PXE boot infrastructure
- `nvme_provision.yml` — NVMe preparation and provisioning
- `network_setup.yml` — basic network configuration for nodes
- `ssh_setup.yml` — configure SSH users and keys
- `rpi_bootmode.yml` — set Raspberry Pi bootmode (USB/SD)
- `cluster_shutdown.yml` / `cluster_reboot.yml` — orderly shutdown / reboot
- `system_config.yml` — miscellaneous system configuration
- `switch_control.yml` — control managed switch port power (if supported)
- `compatibility.yml` — run basic compatibility checks across nodes

This is not an exhaustive list — check `playbooks/` for the complete set.

## Inventories and variables

- Inventory files live under `inventories/production/` by default.
- Global variables and secrets are stored under `inventories/production/group_vars/` (for example, `all/` and `all/vault.yml`).
- Per-host variables can be placed in `inventories/production/host_vars/`.

Secrets: if you use Ansible Vault, keep encrypted values in `group_vars/*/vault.yml` and provide the vault password at runtime using `--vault-password-file` or `ANSIBLE_VAULT_PASSWORD_FILE`.

## Roles

Each role in `roles/` follows the standard Ansible role layout (tasks, handlers, templates, files, defaults, vars, meta). Roles are designed to be composable and are referenced from the top-level playbooks.

## Troubleshooting & tips

- Test connectivity first:

```bash
ansible all -i inventories/production/hosts -m ping
```

- Run a playbook in check (dry-run) mode:

```bash
ansible-playbook -i inventories/production/hosts playbooks/k3s_install.yml --check
```

- Use `ANSIBLE_VERBOSE` or `-v` for more output when debugging.
- Lint playbooks with `ansible-lint` and follow suggestions from CI (GitHub Actions configured for linting).

## Contributing

- Open issues and PRs. Add tests or example inventories where applicable.
- Keep changes focused to one role/playbook per PR and update role documentation.
- Run `make lint` and fix warnings before submitting a PR.

## License

See `LICENSE` if present. If not, please contact the repository owner for licensing details.

## Contact / Maintainers

If you need help, open an issue or contact the repository owner.
