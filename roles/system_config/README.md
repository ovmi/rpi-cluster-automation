# Ansible Role: system_config

This role is used to apply system configuration settings across all nodes in the cluster.

## 📋 Features

- Applies system-level configurations such as:
  - Kernel parameters
  - Hostname settings
  - Locale/timezone configuration
  - Network tweaks
- Uses `become: true` to apply privileged changes
- Designed to run on both control and worker nodes

## 🚀 Usage

Include this role in a playbook targeting your cluster:

```yaml
- name: Configure system parameters across cluster
  hosts: cluster
  become: true
  roles:
    - system_config
```

Or run it using the existing playbook:

```bash
ansible-playbook playbooks/system_config.yml
```

## 🔧 Role Variables

You can define custom system settings in:

```yaml
roles/system_config/vars/main.yml
```

Example:

```yaml
system_timezone: Europe/Bucharest
```

## 🧪 Tested On

- Raspberry Pi OS
- Ubuntu 20.04 / 22.04

## 📂 Structure

```
system_config/
├── files/
├── tasks/
├── vars/
└── README.md
```

