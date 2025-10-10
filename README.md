# Ansible Cluster Automation

This repository contains an Ansible-based automation framework for managing a cluster of Raspberry Pi nodes.

## 📁 Project Structure

```
ansible/
├── roles/                      # All functionality modularized into roles
│   └── <role_name>/           # Example: k3s_install, docker_install, etc.
│       ├── tasks/
│       ├── files/
│       ├── templates/
│       ├── defaults/
│       ├── vars/
│       ├── handlers/
│       └── meta/
├── inventories/
│   └── production/
│       ├── hosts              # Inventory file with group definitions
│       └── group_vars/
│           └── all.yml        # Global variables like SSH user and key
├── .github/
│   └── workflows/
│       └── ansible-lint.yml   # GitHub Actions workflow for ansible-lint
├── Makefile                   # CLI shortcuts for common tasks
└── README.md                  # You're reading it!
```

## 🚀 Usage

Run Ansible from a control machine (x86) with access to the cluster via SSH.

### 🔧 Run full playbook
```bash
make run
```

### ✅ Run linting checks
```bash
make lint
```

### 📶 Ping all nodes
```bash
make ping
```

## 🛠️ Requirements

- Python 3.11+
- `ansible`, `ansible-lint`
- SSH access to all nodes in the cluster

## 📦 GitHub Actions

A CI pipeline is included to automatically lint playbooks using `ansible-lint` on push and pull requests.

## 📌 Notes

- You can customize inventory files under `inventories/production/hosts`
- Default SSH user is `pi` with key from `~/.ssh/id_rsa` (configurable in `group_vars/all.yml`)
- Each `role` contains its own logic for configuration
