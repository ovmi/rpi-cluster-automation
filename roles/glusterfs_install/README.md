# Ansible Role: glusterfs_install

This role installs and configures GlusterFS on a Raspberry Pi cluster. One node acts as the brick, the others mount the volume.

## 🧩 Features

- Installs GlusterFS server/client
- Initializes and mounts the brick on a dedicated node
- Probes peers and creates a volume on the control node
- Mounts the volume across all cluster nodes

## 🧾 Example Playbook

```yaml
- name: Setup GlusterFS across the cluster
  hosts: all
  become: true
  vars:
    gluster_brick_node: "rpi-node2"
    gluster_volume_name: "{{ gluster_brick_node }}_volume"
  roles:
    - glusterfs_install
```

## 📂 Role Structure

```
glusterfs_install/
├── tasks/
│   ├── main.yml
│   ├── setup.yml
│   ├── brick_node.yml
│   ├── control_node.yml
│   └── mount_volume.yml
└── README.md
```
