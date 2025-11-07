# Role: k3s_uninstall

**Purpose:** Short description of what `k3s_uninstall` does.

## Usage
```bash
ansible-playbook -i inventories/production playbooks/k3s_uninstall.yml
```

## Variables (defaults)
See `roles/k3s_uninstall/defaults/main.yml` (if present).

## Flow
```mermaid
flowchart TD
  A[Start] --> B[k3s_uninstall tasks]
  B --> C[Done]
```
![k3s_uninstall flow](../../media/k3s_uninstall.png)
