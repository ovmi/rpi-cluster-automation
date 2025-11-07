# Role: cluster_reboot

**Purpose:** Short description of what `cluster_reboot` does.

## Usage
```bash
ansible-playbook -i inventories/production playbooks/cluster_reboot.yml
```

## Variables (defaults)
See `roles/cluster_reboot/defaults/main.yml` (if present).

## Flow
```mermaid
flowchart TD
  A[Start] --> B[cluster_reboot tasks]
  B --> C[Done]
```
![cluster_reboot flow](../../media/cluster_reboot.png)
