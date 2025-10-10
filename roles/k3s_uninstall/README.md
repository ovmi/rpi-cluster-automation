# Ansible Role: k3s_uninstall

This role completely removes K3s from all nodes in a cluster, including binaries, services, configs, and network interfaces.

## ✅ Features

- Stops k3s and k3s-agent if running
- Runs uninstall scripts if present
- Removes related binaries and directories
- Clears iptables and Flannel interface
- Verifies final status

## 🧾 Usage

```yaml
- name: Uninstall K3s
  hosts: all
  become: true
  roles:
    - k3s_uninstall
```

## 📂 Role Structure

```
k3s_uninstall/
├── tasks/
│   └── main.yml
└── README.md
```
