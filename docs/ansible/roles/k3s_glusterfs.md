# Role: k3s_glusterfs

**Purpose:** Short description of what `k3s_glusterfs` does.

## Usage
```bash
ansible-playbook -i inventories/production playbooks/k3s_glusterfs.yml
```

## Variables (defaults)
See `roles/k3s_glusterfs/defaults/main.yml` (if present).

## Flow
```mermaid
flowchart TD
  A[Start] --> B[k3s_glusterfs tasks]
  B --> C[Done]
```
![k3s_glusterfs flow](../../media/k3s_glusterfs.png)
