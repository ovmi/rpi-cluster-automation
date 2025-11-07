# Ansible Role: ssh_config

This role manages the SSH configuration and key-based authentication setup for a Raspberry Pi (or other) cluster.

## 📋 Features

- Generates a new SSH key pair on the control machine if not already present
- Cleans up existing SSH known host entries
- Scans host keys using `ssh-keyscan` and updates `known_hosts`
- Tests existing SSH connectivity
- If connectivity fails, uses `sshpass` and `ssh-copy-id` to deploy the public key
- Ensures the key is installed in `authorized_keys` on all worker nodes

## 📁 Directory Structure

```text
ssh_config/
├── defaults/
│   └── main.yml
├── files/
├── handlers/
├── meta/
│   └── main.yml
├── tasks/
│   └── main.yml
├── templates/
├── vars/
└── README.md
```

## 🔧 Role Variables

Defined in `defaults/main.yml`:

```yaml
ansible_user: node0
ansible_ssh_private_key_file: id_rsa_cluster
ansible_ssh_public_key_file: id_rsa_cluster.pub
```

## 🚀 Usage

Include this role in your playbook like so:

```yaml
- name: Setup SSH configuration and distribute keys
  hosts: localhost
  connection: local
  gather_facts: false

  roles:
    - ssh_config
```

## 📦 Requirements

- `sshpass` installed on the control machine
- Python 3.6+ and `ansible-core` 2.10+

## 🧪 Tested On

- Raspberry Pi OS (Debian 11)
- Ubuntu 22.04 (control node)
